# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE NETWORKING
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "quorum_cluster" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "quorum_cluster" {
  vpc_id = "${aws_vpc.quorum_cluster.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "quorum_cluster" {
  route_table_id         = "${aws_vpc.quorum_cluster.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.quorum_cluster.id}"
}

resource "aws_subnet" "quorum_cluster" {
  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  count                   = "${length(var.quorum_azs[var.aws_region])}"
  availability_zone       = "${element(var.quorum_azs[var.aws_region], count.index)}"
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

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${aws_s3_bucket.quorum_constellation.id} /opt/quorum/constellation/private/s3fs fuse.s3fs _netdev,allow_other,iam_role 0 0' | sudo tee /etc/fstab",
      "sudo mount -a",
      "echo '${count.index}' | sudo tee /opt/quorum/info/role-index.txt",
      "echo '${count.index}' | sudo tee /opt/quorum/info/overall-index.txt",
      # TODO: Fill in all regions
      "echo '${lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/node-counts/${var.aws_region}.txt",
      "echo '${lookup(var.maker_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/maker-counts/${var.aws_region}.txt",
      "echo '${lookup(var.validator_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/validator-counts/${var.aws_region}.txt",
      "echo '${lookup(var.observer_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/observer-counts/${var.aws_region}.txt",
      "echo '${lookup(var.bootnode_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/bootnode-counts/${var.aws_region}.txt",
      "echo 'maker' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.aws_region}' | sudo tee /opt/quorum/info/aws-region.txt",
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
      # TODO: Fill in all regions
      "echo '${lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/node-counts/${var.aws_region}.txt",
      "echo '${lookup(var.maker_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/maker-counts/${var.aws_region}.txt",
      "echo '${lookup(var.validator_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/validator-counts/${var.aws_region}.txt",
      "echo '${lookup(var.observer_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/observer-counts/${var.aws_region}.txt",
      "echo '${lookup(var.bootnode_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/bootnode-counts/${var.aws_region}.txt",
      "echo 'validator' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.aws_region}' | sudo tee /opt/quorum/info/aws-region.txt",
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
      # TODO: Fill in all regions
      "echo '${lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/node-counts/${var.aws_region}.txt",
      "echo '${lookup(var.maker_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/maker-counts/${var.aws_region}.txt",
      "echo '${lookup(var.validator_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/validator-counts/${var.aws_region}.txt",
      "echo '${lookup(var.observer_node_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/observer-counts/${var.aws_region}.txt",
      "echo '${lookup(var.bootnode_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/bootnode-counts/${var.aws_region}.txt",
      "echo 'observer' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.aws_region}' | sudo tee /opt/quorum/info/aws-region.txt",
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
  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    vault_dns  = "${aws_lb.quorum_vault.dns_name}"
    vault_port = 8200

    consul_cluster_tag_key   = "${module.consul_cluster.cluster_tag_key}"
    consul_cluster_tag_value = "${module.consul_cluster.cluster_tag_value}"

    vault_cert_bucket = "${aws_s3_bucket.vault_certs.bucket}"
  }

  # user-data needs to download these objects
  depends_on = ["aws_s3_bucket_object.vault_ca_public_key", "aws_s3_bucket_object.vault_public_key", "aws_s3_bucket_object.vault_private_key"]
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "quorum" {
  name        = "quorum_nodes"
  description = "Used for quorum nodes"
  vpc_id      = "${aws_vpc.quorum_cluster.id}"
}

resource "aws_security_group_rule" "quorum_ssh" {
  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_constellation" {
  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 9000
  to_port   = 9000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_quorum" {
  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_rpc" {
  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 22000
  to_port   = 22000
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "quorum_bootnode" {
  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 30301
  to_port   = 30301
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_egress" {
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
  name = "quorum-node-network-${var.network_id}"

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
  role       = "${aws_iam_role.quorum_node.name}"
  policy_arn = "${aws_iam_policy.quorum.arn}"
}

resource "aws_iam_instance_profile" "quorum_node" {
  name = "quorum-node-network-${var.network_id}"
  role = "${aws_iam_role.quorum_node.name}"
}
