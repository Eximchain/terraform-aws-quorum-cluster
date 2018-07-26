# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  version = "~> 1.5"

  region  = "${var.aws_region}"
}

provider "null" {
  version = "~> 1.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY PAIR FOR ALL INSTANCES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_key_pair" "auth" {
  key_name   = "quorum-vault-network-${var.network_id}"
  public_key = "${var.public_key}"
}

# ---------------------------------------------------------------------------------------------------------------------
# KMS UNSEAL KEY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "vault_unseal" {
  # Create only if we're using vault enterprise
  count = "${var.vault_enterprise_license_key == "" ? 0 : 1}"

  description = "Key to unseal vault for quorum network ${var.network_id}"

  # 7 Days for a network we expect to be ephemeral, otherwise 30 days
  deletion_window_in_days = "${var.force_destroy_s3_bucket ? 7 : 30}"
}

resource "aws_kms_grant" "vault_unseal" {
  # Create only if we're using vault enterprise
  count = "${var.vault_enterprise_license_key == "" ? 0 : 1}"

  key_id            = "${aws_kms_key.vault_unseal.key_id}"
  grantee_principal = "${module.vault_cluster.iam_role_arn}"

  operations = [ "Encrypt", "Decrypt", "DescribeKey" ]
}

# ---------------------------------------------------------------------------------------------------------------------
# VAULT CLUSTER NETWORKING
# ---------------------------------------------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vault" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "vault" {
  vpc_id = "${aws_vpc.vault.id}"
}

resource "aws_route" "vault" {
  route_table_id         = "${aws_vpc.vault.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.vault.id}"
}

resource "aws_subnet" "vault" {
  vpc_id                  = "${aws_vpc.vault.id}"
  count                   = "${length(data.aws_availability_zones.available.names)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block              = "192.168.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
}

# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKET FOR VAULT BACKEND
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "quorum_vault" {
  bucket_prefix = "quorum-vault-network-${var.network_id}-"
}

# ---------------------------------------------------------------------------------------------------------------------
# LOAD BALANCER FOR VAULT
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "quorum_vault" {
  internal = false

  subnets         = ["${aws_subnet.vault.*.id}"]
  security_groups = ["${module.vault_cluster.security_group_id}"]
}

resource "aws_lb_target_group" "quorum_vault" {
  name = "vault-lb-target-net-${var.network_id}"
  port = "${var.vault_port}"
  protocol = "HTTPS"
  vpc_id = "${aws_vpc.vault.id}"
}

resource "aws_lb_listener" "quorum_vault" {
  load_balancer_arn = "${aws_lb.quorum_vault.arn}"
  port              = "${var.vault_port}"
  protocol          = "HTTPS"
  ssl_policy        = "${var.lb_ssl_policy}"
  certificate_arn   = "${aws_iam_server_certificate.vault_certs.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.quorum_vault.arn}"
    type             = "forward"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AMIs
# ---------------------------------------------------------------------------------------------------------------------
data "aws_ami" "vault_consul" {
  most_recent = true
  owners      = ["037794263736"]

  filter {
    name   = "name"
    values = ["eximchain-vault-quorum-*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE VAULT SERVER CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "vault_cluster" {
  source = "github.com/hashicorp/terraform-aws-vault.git//modules/vault-cluster?ref=v0.0.8"

  cluster_name  = "quorum-vault-network-${var.network_id}"
  cluster_size  = "${var.vault_cluster_size}"
  instance_type = "${var.vault_instance_type}"

  ami_id    = "${var.vault_consul_ami == "" ? data.aws_ami.vault_consul.id : var.vault_consul_ami}"
  user_data = "${data.template_file.user_data_vault_cluster.rendered}"

  s3_bucket_name          = "${aws_s3_bucket.quorum_vault.id}"
  force_destroy_s3_bucket = "${var.force_destroy_s3_bucket}"

  vpc_id     = "${aws_vpc.vault.id}"
  subnet_ids = "${aws_subnet.vault.*.id}"

  tenancy = "${var.use_dedicated_vault_servers ? "dedicated" : "default"}"

  target_group_arns = ["${aws_lb_target_group.quorum_vault.arn}"]

  allowed_ssh_cidr_blocks            = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks        = ["0.0.0.0/0"]
  allowed_inbound_security_group_ids = []
  ssh_key_name                       = "${aws_key_pair.auth.id}"

  cluster_extra_tags = [
    {
      key                 = "Role"
      value               = "Vault"
      propagate_at_launch = true
    },{
      key                 = "NetworkId"
      value               = "${var.network_id}"
      propagate_at_launch = true
    },{
      key                 = "Region"
      value               = "${var.aws_region}"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW VAULT CLUSTER TO USE AWS AUTH
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "allow_aws_auth" {
  name        = "allow_aws_auth_network_${var.network_id}"
  description = "Allow authentication to vault by AWS mechanisms"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole"
    ],
    "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_aws_auth" {
  role       = "${module.vault_cluster.iam_role_id}"
  policy_arn = "${aws_iam_policy.allow_aws_auth.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our Vault servers to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.1.0"

  iam_role_id = "${module.vault_cluster.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH VAULT SERVER WHEN IT'S BOOTING
# This script will configure and start Vault
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data/user-data-vault.sh")}"

  vars {
    aws_region                   = "${var.aws_region}"
    s3_bucket_name               = "${aws_s3_bucket.quorum_vault.id}"
    consul_cluster_tag_key       = "${module.consul_cluster.cluster_tag_key}"
    consul_cluster_tag_value     = "${module.consul_cluster.cluster_tag_value}"
    network_id                   = "${var.network_id}"
    vault_cert_bucket            = "${aws_s3_bucket.vault_certs.bucket}"
    kms_unseal_key_id            = "${join("", aws_kms_key.vault_unseal.*.key_id)}"
    vault_enterprise_license_key = "${var.vault_enterprise_license_key}"
    threatstack_deploy_key       = "${var.threatstack_deploy_key}"
    maker_node_count_json        = "${data.template_file.maker_node_count_json.rendered}"
    validator_node_count_json    = "${data.template_file.validator_node_count_json.rendered}"
    observer_node_count_json     = "${data.template_file.observer_node_count_json.rendered}"
    bootnode_count_json          = "${data.template_file.bootnode_count_json.rendered}"
  }

  # user-data needs to download these objects
  depends_on = ["aws_s3_bucket_object.vault_ca_public_key", "aws_s3_bucket_object.vault_public_key", "aws_s3_bucket_object.vault_private_key"]
}

# ---------------------------------------------------------------------------------------------------------------------
# NODE COUNT JSONS REQUIRED TO CREATE VAULT POLICIES
# ---------------------------------------------------------------------------------------------------------------------
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
# DEPLOY THE CONSUL SERVER CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "consul_cluster" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.1.2"

  cluster_name  = "quorum-consul"
  cluster_size  = "${var.consul_cluster_size}"
  instance_type = "${var.consul_instance_type}"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "consul-cluster"
  cluster_tag_value = "quorum-consul"

  ami_id    = "${var.vault_consul_ami == "" ? data.aws_ami.vault_consul.id : var.vault_consul_ami}"
  user_data = "${data.template_file.user_data_consul.rendered}"

  vpc_id     = "${aws_vpc.vault.id}"
  subnet_ids = "${aws_subnet.vault.*.id}"

  tenancy = "${var.use_dedicated_consul_servers ? "dedicated" : "default"}"

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${aws_key_pair.auth.id}"

  tags = [
    {
      key                 = "Role"
      value               = "Consul"
      propagate_at_launch = true
    },{
      key                 = "NetworkId"
      value               = "${var.network_id}"
      propagate_at_launch = true
    },{
      key                 = "Region"
      value               = "${var.aws_region}"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER WHEN IT'S BOOTING
# This script will configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_consul" {
  template = "${file("${path.module}/user-data/user-data-consul.sh")}"

  vars {
    consul_cluster_tag_key   = "${module.consul_cluster.cluster_tag_key}"
    consul_cluster_tag_value = "${module.consul_cluster.cluster_tag_value}"
    threatstack_deploy_key   = "${var.threatstack_deploy_key}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# EXPORT CURRENT VAULT SERVER IPS
# These servers may change over time but you can use an arbitrary server for initial setup
# ---------------------------------------------------------------------------------------------------------------------
data "aws_instances" "vault_servers" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["${module.vault_cluster.asg_name}"]
  }
}
