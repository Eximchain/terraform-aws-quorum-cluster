# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE NETWORKING
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "quorum_cluster" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "quorum_cluster" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  vpc_id = "${aws_vpc.quorum_cluster.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "quorum_cluster" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  route_table_id         = "${aws_vpc.quorum_cluster.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.quorum_cluster.id}"
}

resource "aws_subnet" "quorum_cluster" {
  count                   = "${lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) > 0 ? length(data.aws_availability_zones.available.names) : 0}"

  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM MAKER NODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "quorum_maker_node" {
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.quorum_node_instance_type}"
  count         = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  ami       = "${lookup(var.quorum_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_quorum.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.quorum_node.name}"

  vpc_security_group_ids = ["${aws_security_group.quorum.id}"]
  subnet_id              = "${element(aws_subnet.quorum_cluster.*.id, count.index)}"

  tags {
    Name = "quorum-maker-node-${count.index}"
  }

  root_block_device {
    volume_size = "${var.node_volume_size}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${aws_s3_bucket.quorum_constellation.id} /opt/quorum/constellation/private/s3fs fuse.s3fs _netdev,allow_other,iam_role 0 0' | sudo tee /etc/fstab",
      "sudo mount -a",
      "echo '${count.index}' | sudo tee /opt/quorum/info/role-index.txt",
      "echo '${count.index}' | sudo tee /opt/quorum/info/overall-index.txt",
      "echo '${jsonencode(var.maker_node_counts)}' | sudo tee /opt/quorum/info/maker-counts.json",
      "echo '${jsonencode(var.validator_node_counts)}' | sudo tee /opt/quorum/info/validator-counts.json",
      "echo '${jsonencode(var.observer_node_counts)}' | sudo tee /opt/quorum/info/observer-counts.json",
      "echo '${jsonencode(var.bootnode_counts)}' | sudo tee /opt/quorum/info/bootnode-counts.json",
      "sudo python /opt/quorum/bin/fill-node-counts.py --quorum-info-root '/opt/quorum/info'",
      "echo 'maker' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.min_block_time}' | sudo tee /opt/quorum/info/min-block-time.txt",
      "echo '${var.max_block_time}' | sudo tee /opt/quorum/info/max-block-time.txt",
      "echo '${var.gas_limit}' | sudo tee /opt/quorum/info/gas-limit.txt",
      "echo '${var.aws_region}' | sudo tee /opt/quorum/info/aws-region.txt",
      "echo '${var.primary_region}' | sudo tee /opt/quorum/info/primary-region.txt",
      "echo '${var.generate_metrics}' | sudo tee /opt/quorum/info/generate-metrics.txt",
      # This should be last because init scripts wait for this file to determine terraform is done provisioning
      "echo '${var.network_id}' | sudo tee /opt/quorum/info/network-id.txt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM VALIDATOR NODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "quorum_validator_node" {
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.quorum_node_instance_type}"
  count         = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  ami       = "${lookup(var.quorum_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_quorum.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.quorum_node.name}"

  vpc_security_group_ids = ["${aws_security_group.quorum.id}"]
  subnet_id              = "${element(aws_subnet.quorum_cluster.*.id, count.index + lookup(var.maker_node_counts, var.aws_region, 0))}"

  tags {
    Name = "quorum-validator-node-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${aws_s3_bucket.quorum_constellation.id} /opt/quorum/constellation/private/s3fs fuse.s3fs _netdev,allow_other,iam_role 0 0' | sudo tee /etc/fstab",
      "sudo mount -a",
      "echo '${count.index}' | sudo tee /opt/quorum/info/role-index.txt",
      "echo '${lookup(var.maker_node_counts, var.aws_region, 0) + count.index}' | sudo tee /opt/quorum/info/overall-index.txt",
      "echo '${jsonencode(var.maker_node_counts)}' | sudo tee /opt/quorum/info/maker-counts.json",
      "echo '${jsonencode(var.validator_node_counts)}' | sudo tee /opt/quorum/info/validator-counts.json",
      "echo '${jsonencode(var.observer_node_counts)}' | sudo tee /opt/quorum/info/observer-counts.json",
      "echo '${jsonencode(var.bootnode_counts)}' | sudo tee /opt/quorum/info/bootnode-counts.json",
      "sudo python /opt/quorum/bin/fill-node-counts.py --quorum-info-root '/opt/quorum/info'",
      "echo 'validator' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.min_block_time}' | sudo tee /opt/quorum/info/min-block-time.txt",
      "echo '${var.max_block_time}' | sudo tee /opt/quorum/info/max-block-time.txt",
      "echo '${var.gas_limit}' | sudo tee /opt/quorum/info/gas-limit.txt",
      "echo '${var.aws_region}' | sudo tee /opt/quorum/info/aws-region.txt",
      "echo '${var.primary_region}' | sudo tee /opt/quorum/info/primary-region.txt",
      "echo '${var.generate_metrics}' | sudo tee /opt/quorum/info/generate-metrics.txt",
      # This should be last because init scripts wait for this file to determine terraform is done provisioning
      "echo '${var.network_id}' | sudo tee /opt/quorum/info/network-id.txt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM OBSERVER NODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "quorum_observer_node" {
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.quorum_node_instance_type}"
  count         = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  ami       = "${lookup(var.quorum_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_quorum.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.quorum_node.name}"

  vpc_security_group_ids = ["${aws_security_group.quorum.id}"]
  subnet_id              = "${element(aws_subnet.quorum_cluster.*.id, count.index + lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0))}"

  tags {
    Name = "quorum-observer-node-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${aws_s3_bucket.quorum_constellation.id} /opt/quorum/constellation/private/s3fs fuse.s3fs _netdev,allow_other,iam_role 0 0' | sudo tee /etc/fstab",
      "sudo mount -a",
      "echo '${count.index}' | sudo tee /opt/quorum/info/role-index.txt",
      "echo '${lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + count.index}' | sudo tee /opt/quorum/info/overall-index.txt",
      "echo '${jsonencode(var.maker_node_counts)}' | sudo tee /opt/quorum/info/maker-counts.json",
      "echo '${jsonencode(var.validator_node_counts)}' | sudo tee /opt/quorum/info/validator-counts.json",
      "echo '${jsonencode(var.observer_node_counts)}' | sudo tee /opt/quorum/info/observer-counts.json",
      "echo '${jsonencode(var.bootnode_counts)}' | sudo tee /opt/quorum/info/bootnode-counts.json",
      "sudo python /opt/quorum/bin/fill-node-counts.py --quorum-info-root '/opt/quorum/info'",
      "echo 'observer' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.min_block_time}' | sudo tee /opt/quorum/info/min-block-time.txt",
      "echo '${var.max_block_time}' | sudo tee /opt/quorum/info/max-block-time.txt",
      "echo '${var.gas_limit}' | sudo tee /opt/quorum/info/gas-limit.txt",
      "echo '${var.aws_region}' | sudo tee /opt/quorum/info/aws-region.txt",
      "echo '${var.primary_region}' | sudo tee /opt/quorum/info/primary-region.txt",
      "echo '${var.generate_metrics}' | sudo tee /opt/quorum/info/generate-metrics.txt",
      # This should be last because init scripts wait for this file to determine terraform is done provisioning
      "echo '${var.network_id}' | sudo tee /opt/quorum/info/network-id.txt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH QUORUM NODE WHEN IT'S BOOTING
# This script will configure and start the Consul Agent
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_quorum" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    vault_dns  = "${var.vault_dns}"
    vault_port = "${var.vault_port}"

    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_tag_value}"

    vault_cert_bucket = "${var.vault_cert_bucket_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "quorum" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  name        = "quorum_nodes"
  description = "Used for quorum nodes"
  vpc_id      = "${aws_vpc.quorum_cluster.id}"
}

resource "aws_security_group_rule" "quorum_ssh" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_constellation" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 9000
  to_port   = 9000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_quorum" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_rpc" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 22000
  to_port   = 22000
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "quorum_bootnode" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 30301
  to_port   = 30301
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_egress" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum.id}"
  type              = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "quorum_node" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  name = "quorum-node-${var.aws_region}-network-${var.network_id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }]
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE IAM POLICY ATTACHMENT AND INSTANCE PROFILE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "quorum_node" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  role       = "${aws_iam_role.quorum_node.name}"
  policy_arn = "${aws_iam_policy.quorum.arn}"
}

resource "aws_iam_instance_profile" "quorum_node" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  name = "quorum-node-${var.aws_region}-network-${var.network_id}"
  role = "${aws_iam_role.quorum_node.name}"
}
