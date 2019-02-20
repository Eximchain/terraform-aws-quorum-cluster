# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
#  version = "~> 1.5"
  version = "1.56.0"

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
  count = "${var.pre_baked_vault_enterprise_license ? 1 : var.vault_enterprise_license_key == "" ? 0 : 1}"

  description = "Key to unseal vault for quorum network ${var.network_id}"

  # 7 Days for a network we expect to be ephemeral, otherwise 30 days
  deletion_window_in_days = "${var.force_destroy_s3_bucket ? 7 : 30}"
}

resource "aws_kms_grant" "vault_unseal" {
  # Create only if we're using vault enterprise
  count = "${var.pre_baked_vault_enterprise_license ? 1 : var.vault_enterprise_license_key == "" ? 0 : 1}"

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
  cidr_block           = "${var.vault_consul_vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name      = "quorum-network-${var.network_id}-vault-consul"
    VpcType   = "VaultConsul"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
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
  count = "${lookup(var.az_override, var.aws_region, "") == "" ? length(data.aws_availability_zones.available.names) : length(split(",", lookup(var.az_override, var.aws_region, "")))}"

  vpc_id                  = "${aws_vpc.vault_consul.id}"
  availability_zone       = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(split(",", lookup(var.az_override, var.aws_region, "")), count.index)}"
  cidr_block              = "192.168.${count.index + 1}.0/24"
  map_public_ip_on_launch = true

  tags {
    Name      = "quorum-network-${var.network_id}-vault-consul"
    NodeType  = "VaultConsul"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AMIs
# ---------------------------------------------------------------------------------------------------------------------
data "aws_ami" "vault_consul" {
  count = "${var.vault_consul_ami == "" ? 1 : 0}"

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
  name   = "auto-discover-cluster-net-${var.network_id}"
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
# IAM POLICY TO ACCESS NODE COUNT BUCKET
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "node_count_access" {
  name        = "node-count-access-network-${var.network_id}"
  description = "Allow read access to the node count bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:ListBucket"],
    "Resource": ["${var.node_count_bucket_arn}"]
  },{
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource": ["${var.node_count_bucket_arn}/*"]
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node_count_access" {
  role       = "${aws_iam_role.vault_cluster.id}"
  policy_arn = "${aws_iam_policy.node_count_access.arn}"
}
