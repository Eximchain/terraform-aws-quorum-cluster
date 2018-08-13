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
  grantee_principal = "${aws_iam_role.vault_cluster.arn}"

  operations = [ "Encrypt", "Decrypt", "DescribeKey" ]
}

# ---------------------------------------------------------------------------------------------------------------------
# VAULT CLUSTER NETWORKING
# ---------------------------------------------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vault_consul" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_default_security_group" "vault_consul" {
  count = "${aws_vpc.vault_consul.count}"

  vpc_id = "${aws_vpc.vault_consul.id}"
}

resource "aws_internet_gateway" "vault_consul" {
  vpc_id = "${aws_vpc.vault_consul.id}"
}

resource "aws_route" "vault_consul" {
  route_table_id         = "${aws_vpc.vault_consul.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.vault_consul.id}"
}

resource "aws_subnet" "vault_consul" {
  vpc_id                  = "${aws_vpc.vault_consul.id}"
  count                   = "${length(data.aws_availability_zones.available.names)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block              = "192.168.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
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
# ATTACH IAM POLICIES FOR CONSUL
# To allow our Vault servers to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.1.0"

  iam_role_id = "${aws_iam_role.vault_cluster.id}"
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

  vpc_id     = "${aws_vpc.vault_consul.id}"
  subnet_ids = "${aws_subnet.vault_consul.*.id}"

  tenancy = "${var.use_dedicated_consul_servers ? "dedicated" : "default"}"

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.

  allowed_ssh_cidr_blocks     = []
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

# TODO: Swap to list interpolation for cidr_blocks once Terraform v0.12 is released, consider inputting list directly to module
resource "aws_security_group_rule" "consul_ssh" {
  count = "${length(var.ssh_ips) > 0 ? length(var.ssh_ips) : 1}"

  security_group_id = "${module.consul_cluster.security_group_id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["${length(var.ssh_ips) == 0 ? "0.0.0.0/0" : format("%s/32", element(concat(var.ssh_ips, list("")), count.index))}"]
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
