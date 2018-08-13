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
# KMS UNSEAL KEY FOR ENTERPRISE
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
# NETWORKING
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
# CONSUL AUTO-DISCOVER POLICY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "auto_discover_cluster" {
  name   = "auto-discover-cluster"
  policy = "${data.aws_iam_policy_document.auto_discover_cluster.json}"

  description = "Allow consul cluster auto-discovery"
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ASSUME ROLE POLICY DOCUMENT
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
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
