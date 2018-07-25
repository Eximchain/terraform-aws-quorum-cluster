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
# QUORUM NODE ASGs
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "quorum_maker" {
  count = "${aws_launch_configuration.quorum_maker.count}"

  name = "quorum-maker-net-${var.network_id}-node-${count.index}"

  launch_configuration = "${element(aws_launch_configuration.quorum_maker.*.name, count.index)}"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = ["${element(aws_subnet.quorum_cluster.*.id, count.index)}"]
}

resource "aws_autoscaling_group" "quorum_validator" {
  count = "${aws_launch_configuration.quorum_validator.count}"

  name = "quorum-validator-net-${var.network_id}-node-${count.index}"

  launch_configuration = "${element(aws_launch_configuration.quorum_validator.*.name, count.index)}"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = ["${element(aws_subnet.quorum_cluster.*.id, count.index)}"]
}

resource "aws_autoscaling_group" "quorum_observer" {
  count = "${aws_launch_configuration.quorum_observer.count}"

  name = "quorum-observer-net-${var.network_id}-node-${count.index}"

  launch_configuration = "${element(aws_launch_configuration.quorum_observer.*.name, count.index)}"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = ["${element(aws_subnet.quorum_cluster.*.id, count.index)}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# USER DATA SCRIPTS
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" "user_data_quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    index              = "${count.index}"
    overall_index_base = 0

    role = "maker"

    aws_region     = "${var.aws_region}"
    primary_region = "${var.primary_region}"

    vote_threshold   = "${var.vote_threshold}"
    min_block_time   = "${var.min_block_time}"
    max_block_time   = "${var.max_block_time}"
    gas_limit        = "${var.gas_limit}"
    network_id       = "${var.network_id}"

    generate_metrics   = "${var.generate_metrics}"
    data_backup_bucket = "${var.data_backup_bucket}"

    maker_node_count_json     = "${data.template_file.maker_node_count_json.rendered}"
    validator_node_count_json = "${data.template_file.validator_node_count_json.rendered}"
    observer_node_count_json  = "${data.template_file.observer_node_count_json.rendered}"
    bootnode_count_json       = "${data.template_file.bootnode_count_json.rendered}"

    vault_dns  = "${var.vault_dns}"
    vault_port = "${var.vault_port}"

    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_tag_value}"

    vault_cert_bucket       = "${var.vault_cert_bucket_name}"
    constellation_s3_bucket = "${aws_s3_bucket.quorum_constellation.id}"

    threatstack_deploy_key = "${var.threatstack_deploy_key}"
  }
}

data "template_file" "user_data_quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    index              = "${count.index}"
    overall_index_base = "${data.template_file.user_data_quorum_maker.count}"

    role = "validator"

    aws_region     = "${var.aws_region}"
    primary_region = "${var.primary_region}"

    vote_threshold   = "${var.vote_threshold}"
    min_block_time   = "${var.min_block_time}"
    max_block_time   = "${var.max_block_time}"
    gas_limit        = "${var.gas_limit}"
    network_id       = "${var.network_id}"

    generate_metrics = "${var.generate_metrics}"
    data_backup_bucket = "${var.data_backup_bucket}"

    maker_node_count_json     = "${data.template_file.maker_node_count_json.rendered}"
    validator_node_count_json = "${data.template_file.validator_node_count_json.rendered}"
    observer_node_count_json  = "${data.template_file.observer_node_count_json.rendered}"
    bootnode_count_json       = "${data.template_file.bootnode_count_json.rendered}"

    vault_dns  = "${var.vault_dns}"
    vault_port = "${var.vault_port}"

    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_tag_value}"

    vault_cert_bucket       = "${var.vault_cert_bucket_name}"
    constellation_s3_bucket = "${aws_s3_bucket.quorum_constellation.id}"

    threatstack_deploy_key = "${var.threatstack_deploy_key}"
  }
}

data "template_file" "user_data_quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    index              = "${count.index}"
    overall_index_base = "${data.template_file.user_data_quorum_maker.count + data.template_file.user_data_quorum_validator.count}"

    role = "observer"

    aws_region     = "${var.aws_region}"
    primary_region = "${var.primary_region}"

    vote_threshold   = "${var.vote_threshold}"
    min_block_time   = "${var.min_block_time}"
    max_block_time   = "${var.max_block_time}"
    gas_limit        = "${var.gas_limit}"
    network_id       = "${var.network_id}"

    generate_metrics = "${var.generate_metrics}"
    data_backup_bucket = "${var.data_backup_bucket}"

    maker_node_count_json     = "${data.template_file.maker_node_count_json.rendered}"
    validator_node_count_json = "${data.template_file.validator_node_count_json.rendered}"
    observer_node_count_json  = "${data.template_file.observer_node_count_json.rendered}"
    bootnode_count_json       = "${data.template_file.bootnode_count_json.rendered}"

    vault_dns  = "${var.vault_dns}"
    vault_port = "${var.vault_port}"

    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_tag_value}"

    vault_cert_bucket       = "${var.vault_cert_bucket_name}"
    constellation_s3_bucket = "${aws_s3_bucket.quorum_constellation.id}"

    threatstack_deploy_key = "${var.threatstack_deploy_key}"
  }
}

data "template_file" "maker_node_count_json" {
  template = "${file("${path.module}/templates/node-count.json")}"

  vars {
    ap_northeast_1_count = "${lookup(var.maker_node_counts, "ap-northeast-1", 0)}"
    ap_northeast_2_count = "${lookup(var.maker_node_counts, "ap-northeast-2", 0)}"
    ap_south_1_count     = "${lookup(var.maker_node_counts, "ap-south-1", 0)}"
    ap_southeast_1_count = "${lookup(var.maker_node_counts, "ap-southeast-1", 0)}"
    ap_southeast_2_count = "${lookup(var.maker_node_counts, "ap-southeast-2", 0)}"
    ca_central_1_count   = "${lookup(var.maker_node_counts, "ca-central-1", 0)}"
    eu_central_1_count   = "${lookup(var.maker_node_counts, "eu-central-1", 0)}"
    eu_west_1_count      = "${lookup(var.maker_node_counts, "eu-west-1", 0)}"
    eu_west_2_count      = "${lookup(var.maker_node_counts, "eu-west-2", 0)}"
    sa_east_1_count      = "${lookup(var.maker_node_counts, "sa-east-1", 0)}"
    us_east_1_count      = "${lookup(var.maker_node_counts, "us-east-1", 0)}"
    us_east_2_count      = "${lookup(var.maker_node_counts, "us-east-2", 0)}"
    us_west_1_count      = "${lookup(var.maker_node_counts, "us-west-1", 0)}"
    us_west_2_count      = "${lookup(var.maker_node_counts, "us-west-2", 0)}"
  }
}

data "template_file" "validator_node_count_json" {
  template = "${file("${path.module}/templates/node-count.json")}"

  vars {
    ap_northeast_1_count = "${lookup(var.validator_node_counts, "ap-northeast-1", 0)}"
    ap_northeast_2_count = "${lookup(var.validator_node_counts, "ap-northeast-2", 0)}"
    ap_south_1_count     = "${lookup(var.validator_node_counts, "ap-south-1", 0)}"
    ap_southeast_1_count = "${lookup(var.validator_node_counts, "ap-southeast-1", 0)}"
    ap_southeast_2_count = "${lookup(var.validator_node_counts, "ap-southeast-2", 0)}"
    ca_central_1_count   = "${lookup(var.validator_node_counts, "ca-central-1", 0)}"
    eu_central_1_count   = "${lookup(var.validator_node_counts, "eu-central-1", 0)}"
    eu_west_1_count      = "${lookup(var.validator_node_counts, "eu-west-1", 0)}"
    eu_west_2_count      = "${lookup(var.validator_node_counts, "eu-west-2", 0)}"
    sa_east_1_count      = "${lookup(var.validator_node_counts, "sa-east-1", 0)}"
    us_east_1_count      = "${lookup(var.validator_node_counts, "us-east-1", 0)}"
    us_east_2_count      = "${lookup(var.validator_node_counts, "us-east-2", 0)}"
    us_west_1_count      = "${lookup(var.validator_node_counts, "us-west-1", 0)}"
    us_west_2_count      = "${lookup(var.validator_node_counts, "us-west-2", 0)}"
  }
}

data "template_file" "observer_node_count_json" {
  template = "${file("${path.module}/templates/node-count.json")}"

  vars {
    ap_northeast_1_count = "${lookup(var.observer_node_counts, "ap-northeast-1", 0)}"
    ap_northeast_2_count = "${lookup(var.observer_node_counts, "ap-northeast-2", 0)}"
    ap_south_1_count     = "${lookup(var.observer_node_counts, "ap-south-1", 0)}"
    ap_southeast_1_count = "${lookup(var.observer_node_counts, "ap-southeast-1", 0)}"
    ap_southeast_2_count = "${lookup(var.observer_node_counts, "ap-southeast-2", 0)}"
    ca_central_1_count   = "${lookup(var.observer_node_counts, "ca-central-1", 0)}"
    eu_central_1_count   = "${lookup(var.observer_node_counts, "eu-central-1", 0)}"
    eu_west_1_count      = "${lookup(var.observer_node_counts, "eu-west-1", 0)}"
    eu_west_2_count      = "${lookup(var.observer_node_counts, "eu-west-2", 0)}"
    sa_east_1_count      = "${lookup(var.observer_node_counts, "sa-east-1", 0)}"
    us_east_1_count      = "${lookup(var.observer_node_counts, "us-east-1", 0)}"
    us_east_2_count      = "${lookup(var.observer_node_counts, "us-east-2", 0)}"
    us_west_1_count      = "${lookup(var.observer_node_counts, "us-west-1", 0)}"
    us_west_2_count      = "${lookup(var.observer_node_counts, "us-west-2", 0)}"
  }
}

data "template_file" "bootnode_count_json" {
  template = "${file("${path.module}/templates/node-count.json")}"

  vars {
    ap_northeast_1_count = "${lookup(var.bootnode_counts, "ap-northeast-1", 0)}"
    ap_northeast_2_count = "${lookup(var.bootnode_counts, "ap-northeast-2", 0)}"
    ap_south_1_count     = "${lookup(var.bootnode_counts, "ap-south-1", 0)}"
    ap_southeast_1_count = "${lookup(var.bootnode_counts, "ap-southeast-1", 0)}"
    ap_southeast_2_count = "${lookup(var.bootnode_counts, "ap-southeast-2", 0)}"
    ca_central_1_count   = "${lookup(var.bootnode_counts, "ca-central-1", 0)}"
    eu_central_1_count   = "${lookup(var.bootnode_counts, "eu-central-1", 0)}"
    eu_west_1_count      = "${lookup(var.bootnode_counts, "eu-west-1", 0)}"
    eu_west_2_count      = "${lookup(var.bootnode_counts, "eu-west-2", 0)}"
    sa_east_1_count      = "${lookup(var.bootnode_counts, "sa-east-1", 0)}"
    us_east_1_count      = "${lookup(var.bootnode_counts, "us-east-1", 0)}"
    us_east_2_count      = "${lookup(var.bootnode_counts, "us-east-2", 0)}"
    us_west_1_count      = "${lookup(var.bootnode_counts, "us-west-1", 0)}"
    us_west_2_count      = "${lookup(var.bootnode_counts, "us-west-2", 0)}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LAUNCH CONFIGURATIONS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "quorum_maker" {
  count = "${data.template_file.user_data_quorum_maker.count}"

  name_prefix = "quorum-maker-net-${var.network_id}-node-${count.index}"

  image_id      = "${var.quorum_ami == "" ? data.aws_ami.quorum.id : var.quorum_ami}"
  instance_type = "${var.quorum_maker_instance_type}"
  user_data     = "${element(data.template_file.user_data_quorum_maker.*.rendered, count.index)}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${element(aws_iam_instance_profile.quorum_maker.*.name, count.index)}"
  security_groups      = ["${aws_security_group.quorum.id}"]

  placement_tenancy = "${var.use_dedicated_makers ? "dedicated" : "default"}"

  root_block_device {
    volume_size = "${var.node_volume_size}"
  }
}

resource "aws_launch_configuration" "quorum_validator" {
  count = "${data.template_file.user_data_quorum_validator.count}"

  name_prefix = "quorum-validator-net-${var.network_id}-node-${count.index}"

  image_id      = "${var.quorum_ami == "" ? data.aws_ami.quorum.id : var.quorum_ami}"
  instance_type = "${var.quorum_validator_instance_type}"
  user_data     = "${element(data.template_file.user_data_quorum_validator.*.rendered, count.index)}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${element(aws_iam_instance_profile.quorum_validator.*.name, count.index)}"
  security_groups      = ["${aws_security_group.quorum.id}"]

  placement_tenancy = "${var.use_dedicated_validators ? "dedicated" : "default"}"

  root_block_device {
    volume_size = "${var.node_volume_size}"
  }
}

resource "aws_launch_configuration" "quorum_observer" {
  count = "${data.template_file.user_data_quorum_observer.count}"

  name_prefix = "quorum-observer-net-${var.network_id}-node-${count.index}"

  image_id      = "${var.quorum_ami == "" ? data.aws_ami.quorum.id : var.quorum_ami}"
  instance_type = "${var.quorum_observer_instance_type}"
  user_data     = "${element(data.template_file.user_data_quorum_observer.*.rendered, count.index)}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${element(aws_iam_instance_profile.quorum_observer.*.name, count.index)}"
  security_groups      = ["${aws_security_group.quorum.id}"]

  placement_tenancy = "${var.use_dedicated_observers ? "dedicated" : "default"}"

  root_block_device {
    volume_size = "${var.node_volume_size}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AMI
# ---------------------------------------------------------------------------------------------------------------------
data "aws_ami" "quorum" {
  most_recent = true
  owners      = ["037794263736"]

  filter {
    name   = "name"
    values = ["eximchain-network-quorum-*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OUTPUT INSTANCES
# ---------------------------------------------------------------------------------------------------------------------
data "aws_instance" "quorum_maker_node" {
  count = "${aws_autoscaling_group.quorum_maker.count}"

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["${element(aws_autoscaling_group.quorum_maker.*.name, count.index)}"]
  }

  depends_on = ["aws_autoscaling_group.quorum_maker"]
}

data "aws_instance" "quorum_validator_node" {
  count = "${aws_autoscaling_group.quorum_validator.count}"

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["${element(aws_autoscaling_group.quorum_validator.*.name, count.index)}"]
  }

  depends_on = ["aws_autoscaling_group.quorum_validator"]
}

data "aws_instance" "quorum_observer_node" {
  count = "${aws_autoscaling_group.quorum_observer.count}"

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["${element(aws_autoscaling_group.quorum_observer.*.name, count.index)}"]
  }

  depends_on = ["aws_autoscaling_group.quorum_observer"]
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

resource "aws_security_group_rule" "quorum_udp" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "udp"

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

resource "aws_security_group_rule" "supervisor_rpc" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum.id}"
  type              = "ingress"

  from_port = 9001
  to_port   = 9001
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
resource "aws_iam_role" "quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-makers-${count.index}"

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

resource "aws_iam_role" "quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-validators-${count.index}"

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

resource "aws_iam_role" "quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-observers-${count.index}"

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
resource "aws_iam_role_policy_attachment" "quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  role       = "${element(aws_iam_role.quorum_maker.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.quorum.arn}"
}

resource "aws_iam_instance_profile" "quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-makers-${count.index}"
  role = "${element(aws_iam_role.quorum_maker.*.name, count.index)}"
}

resource "aws_iam_role_policy_attachment" "quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  role       = "${element(aws_iam_role.quorum_validator.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.quorum.arn}"
}

resource "aws_iam_instance_profile" "quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-validators-${count.index}"
  role = "${element(aws_iam_role.quorum_validator.*.name, count.index)}"
}

resource "aws_iam_role_policy_attachment" "quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  role       = "${element(aws_iam_role.quorum_observer.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.quorum.arn}"
}

resource "aws_iam_instance_profile" "quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-observers-${count.index}"
  role = "${element(aws_iam_role.quorum_observer.*.name, count.index)}"
}
