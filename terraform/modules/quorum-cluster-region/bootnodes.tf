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
# BOOTNODE LAUNCH CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "bootnodes" {
  count = "${lookup(var.bootnode_counts, var.aws_region, 0)}"

  name_prefix = "quorum-bootnode-net-${var.network_id}-node-${count.index}-"

  image_id   = "${var.bootnode_ami == "" ? data.aws_ami.bootnode.id : var.bootnode_ami}"
  instance_type = "${var.bootnode_instance_type}"
  user_data = "${element(data.template_file.user_data_bootnode.*.rendered, count.index)}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${element(aws_iam_instance_profile.bootnode.*.name, count.index)}"
  security_groups = ["${aws_security_group.bootnode.id}"]

  placement_tenancy = "${var.use_dedicated_bootnodes ? "dedicated" : "default"}"
}

# ---------------------------------------------------------------------------------------------------------------------
# BOOTNODE ASG & ELASTIC IPs
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "bootnodes" {
  count = "${aws_launch_configuration.bootnodes.count}"

  name = "bootnode-net-${var.network_id}-node-${count.index}"

  launch_configuration = "${element(aws_launch_configuration.bootnodes.*.name, count.index)}"

  min_size = 1
  max_size = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type = "ELB"

  vpc_zone_identifier = ["${element(aws_subnet.bootnodes.*.id, count.index)}"]
}

resource "aws_eip" "bootnodes" {
  count = "${var.use_elastic_bootnode_ips ? lookup(var.bootnode_counts, var.aws_region, 0) : 0}"
  vpc = true
}

data "aws_instance" "bootnodes" {
  count = "${aws_autoscaling_group.bootnodes.count}"

  filter {
    name = "tag:aws:autoscaling:groupName"
    values = ["${element(aws_autoscaling_group.bootnodes.*.name, count.index)}"]
  }

  depends_on = ["aws_autoscaling_group.bootnodes"]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH BOOTNODE WHEN IT'S BOOTING
# This script will configure and start the Consul Agent
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_bootnode" {

  count = "${lookup(var.bootnode_counts, var.aws_region, 0)}"

  template = "${file("${path.module}/user-data/user-data-bootnode.sh")}"

  vars {
    constellation_s3_bucket  = "${aws_s3_bucket.quorum_constellation.id}"
    index                    = "${count.index}"
    bootnode_count_json      = "${data.template_file.bootnode_count_json.rendered}"
    aws_region               = "${var.aws_region}"
    primary_region           = "${var.primary_region}"
    network_id               = "${var.network_id}"
    use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

    # concat() is called to ensure there is always at least one element in the list,
    # as element() cannot be called on empty list.  Solution is hacky, but lazy
    # ternary evaluation will drop in Terraform 0.12: https://www.hashicorp.com/blog/terraform-0-1-2-preview
    # If you're reading this and it has already released, try dropping the concat hack.
    public_ip = "${var.use_elastic_bootnode_ips ? element(concat(aws_eip.bootnodes.*.public_ip, list("")), count.index) : "nil"}"
    eip_id    = "${var.use_elastic_bootnode_ips ? element(concat(aws_eip.bootnodes.*.id, list("")), count.index) : "nil"}"

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
  count = "${lookup(var.bootnode_counts, var.aws_region, 0)}"

  name = "bootnode-${var.aws_region}-network-${var.network_id}-node-${count.index}"

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
  count = "${lookup(var.bootnode_counts, var.aws_region, 0)}"

  role       = "${element(aws_iam_role.bootnode.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.quorum.arn}"
}

resource "aws_iam_instance_profile" "bootnode" {
  count = "${lookup(var.bootnode_counts, var.aws_region, 0)}"

  name = "bootnode-${var.aws_region}-network-${var.network_id}-node-${count.index}"
  role = "${element(aws_iam_role.bootnode.*.name, count.index)}"
}
