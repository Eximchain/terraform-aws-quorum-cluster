# ---------------------------------------------------------------------------------------------------------------------
# BOOTNODE NETWORKING
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "bootnodes" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "bootnodes" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  vpc_id = "${aws_vpc.bootnodes.id}"
}

resource "aws_route" "bootnodes" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  route_table_id         = "${aws_vpc.bootnodes.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.bootnodes.id}"
}

resource "aws_subnet" "bootnodes" {
  count                   = "${lookup(var.bootnode_counts, var.aws_region, 0) > 0 ? length(data.aws_availability_zones.available.names) : 0}"

  vpc_id                  = "${aws_vpc.bootnodes.id}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block              = "172.16.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
}

# ---------------------------------------------------------------------------------------------------------------------
# BOOTNODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "bootnode" {
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.bootnode_instance_type}"
  count         = "${lookup(var.bootnode_counts, var.aws_region, 0)}"

  ami       = "${var.bootnode_ami == "" ? data.aws_ami.bootnode.id : var.bootnode_ami}"
  user_data = "${data.template_file.user_data_bootnode.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.bootnode.name}"

  vpc_security_group_ids = ["${aws_security_group.bootnode.id}"]
  subnet_id              = "${element(aws_subnet.bootnodes.*.id, count.index)}"

  tenancy = "${var.use_dedicated_bootnodes ? "dedicated" : "default"}"

  tags {
    Name = "bootnode-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${aws_s3_bucket.quorum_constellation.id} /opt/quorum/constellation/private/s3fs fuse.s3fs _netdev,allow_other,iam_role 0 0' | sudo tee /etc/fstab",
      "sudo mount -a",
      "echo '${count.index}' | sudo tee /opt/quorum/info/index.txt",
      "echo '${jsonencode(var.bootnode_counts)}' | sudo tee /opt/quorum/info/bootnode-counts.json",
      "sudo python /opt/quorum/bin/fill-node-counts.py --quorum-info-root '/opt/quorum/info' --bootnode",
      "echo '${var.aws_region}' | sudo tee /opt/quorum/info/aws-region.txt",
      "echo '${var.primary_region}' | sudo tee /opt/quorum/info/primary-region.txt",
      # This should be last because init scripts wait for this file to determine terraform is done provisioning
      "echo '${var.network_id}' | sudo tee /opt/quorum/info/network-id.txt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH BOOTNODE WHEN IT'S BOOTING
# This script will configure and start the Consul Agent
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_bootnode" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  template = "${file("${path.module}/user-data/user-data-bootnode.sh")}"

  vars {
    vault_dns  = "${var.vault_dns}"
    vault_port = "${var.vault_port}"

    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_tag_value}"

    vault_cert_bucket = "${var.vault_cert_bucket_name}"

    threatstack_deploy_key = "${var.threatstack_deploy_key}"
  }
}

data "aws_ami" "bootnode" {
  most_recent = true
  owners      = ["037794263736"]

  filter {
    name   = "name"
    values = ["eximchain-network-bootnode-*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# BOOTNODE SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "bootnode" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  name        = "bootnodes"
  description = "Used for quorum bootnodes"
  vpc_id      = "${aws_vpc.bootnodes.id}"
}

resource "aws_security_group_rule" "bootnode_ssh" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_constellation" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 9000
  to_port   = 9000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_quorum" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_quorum_udp" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_rpc" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 22000
  to_port   = 22000
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "bootnode_bootnode" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 30301
  to_port   = 30301
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_egress" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# BOOTNODE IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "bootnode" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  name = "bootnode-${var.aws_region}-network-${var.network_id}"

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
# BOOTNODE IAM POLICY ATTACHMENT AND INSTANCE PROFILE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "bootnode" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  role       = "${aws_iam_role.bootnode.name}"
  policy_arn = "${aws_iam_policy.quorum.arn}"
}

resource "aws_iam_instance_profile" "bootnode" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  name = "bootnode-${var.aws_region}-network-${var.network_id}"
  role = "${aws_iam_role.bootnode.name}"
}
