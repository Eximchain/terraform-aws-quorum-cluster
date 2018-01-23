# ---------------------------------------------------------------------------------------------------------------------
# BOOTNODE NETWORKING
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "bootnodes" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "bootnodes" {
  vpc_id = "${aws_vpc.bootnodes.id}"
}

resource "aws_route" "bootnodes" {
  route_table_id         = "${aws_vpc.bootnodes.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.bootnodes.id}"
}

resource "aws_subnet" "bootnodes" {
  vpc_id                  = "${aws_vpc.bootnodes.id}"
  count                   = "${length(var.quorum_azs[var.aws_region])}"
  availability_zone       = "${element(var.quorum_azs[var.aws_region], count.index)}"
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

  ami       = "${lookup(var.bootnode_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_bootnode.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.bootnode.name}"

  vpc_security_group_ids = ["${aws_security_group.bootnode.id}"]
  subnet_id              = "${element(aws_subnet.bootnodes.*.id, count.index)}"

  tags {
    Name = "bootnode-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${aws_s3_bucket.quorum_constellation.id} /opt/quorum/constellation/private/s3fs fuse.s3fs _netdev,allow_other,iam_role 0 0' | sudo tee /etc/fstab",
      "sudo mount -a",
      "echo '${count.index}' | sudo tee /opt/quorum/info/index.txt",
      # TODO: Fill in all regions
      "echo '${lookup(var.bootnode_counts, var.aws_region, 0)}' | sudo tee /opt/quorum/info/bootnode-counts/${var.aws_region}.txt",
      "echo '${var.aws_region}' | sudo tee /opt/quorum/info/aws-region.txt",
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
  template = "${file("${path.module}/user-data/user-data-bootnode.sh")}"

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
# BOOTNODE SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "bootnode" {
  name        = "bootnodes"
  description = "Used for quorum bootnodes"
  vpc_id      = "${aws_vpc.bootnodes.id}"
}

resource "aws_security_group_rule" "bootnode_ssh" {
  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_constellation" {
  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 9000
  to_port   = 9000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_quorum" {
  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_rpc" {
  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 22000
  to_port   = 22000
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "bootnode_bootnode" {
  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 30301
  to_port   = 30301
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_egress" {
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
  name = "bootnode-network-${var.network_id}"

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
  role       = "${aws_iam_role.bootnode.name}"
  policy_arn = "${aws_iam_policy.quorum.arn}"
}

resource "aws_iam_instance_profile" "bootnode" {
  name = "bootnode-network-${var.network_id}"
  role = "${aws_iam_role.bootnode.name}"
}

