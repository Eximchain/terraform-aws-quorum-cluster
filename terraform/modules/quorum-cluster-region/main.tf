# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  version = "~> 2.4.0"

  region  = "${var.aws_region}"
}

provider "tls" {
  version = "~> 1.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# AVAILABILITY ZONES FOR SUBNETS
# ---------------------------------------------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY PAIR FOR ALL INSTANCES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_key_pair" "auth" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0) + lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  key_name   = "quorum-cluster-${var.aws_region}-network-${var.network_id}"
  public_key = "${var.public_key}"
}

# ---------------------------------------------------------------------------------------------------------------------
# S3FS BUCKET FOR CONSTELLATION PAYLOADS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "quorum_constellation" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0) + lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  bucket        = "constellation-${var.aws_region}-net-${var.network_id}${var.s3_bucket_suffix}"
  force_destroy = "${var.force_destroy_s3_buckets}"
}

# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKET FOR REGIONAL BACKUPS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "quorum_backup" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0) + lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  bucket        = "quorum-backup-${var.aws_region}-network-${var.network_id}${var.s3_bucket_suffix}"
  force_destroy = "${var.force_destroy_s3_buckets}"
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE AND BOOTNODE POLICY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "quorum" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0) + lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  name        = "quorum-policy-${var.aws_region}-network-${var.network_id}"
  description = "A policy for quorum nodes and bootnodes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:DescribeInstances",
      "ec2:DescribeImages",
      "ec2:DescribeTags",
      "ec2:DescribeSnapshots"
    ],
    "Resource": "*"
  },{
    "Effect": "Allow",
    "Action": ["ec2:CreateTags"],
    "Resource": "arn:aws:ec2:*:*:instance/*"
  },{
    "Effect": "Allow",
    "Action": ["s3:*"],
    "Resource": [
      "${aws_s3_bucket.quorum_constellation.arn}",
      "${aws_s3_bucket.quorum_constellation.arn}/*"
    ]
  },{
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:PutObject"
    ],
    "Resource": ["${aws_s3_bucket.quorum_backup.arn}/*"]
  },{
    "Effect": "Allow",
    "Action": ["s3:ListBucket"],
    "Resource": [
      "${var.vault_cert_bucket_arn}",
      "${var.node_count_bucket_arn}",
      "${aws_s3_bucket.quorum_backup.arn}"
    ]
  },{
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource": [
      "${var.vault_cert_bucket_arn}/ca.crt.pem",
      "${var.vault_cert_bucket_arn}/vault.crt.pem",
      "${var.node_count_bucket_arn}/*"
    ]
  },{
    "Effect": "Allow",
    "Action": [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics"
    ],
    "Resource": "*"
  },{
    "Effect": "Allow",
    "Action": ["dynamodb:UpdateItem"],
    "Resource": "*"
  },{
    "Effect": "Allow",
    "Action": ["ec2:AssociateAddress"],
    "Resource": "*"
  }]
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# NETWORKING CIDR RANGES
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" "system_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(var.quorum_vpc_cidr, 0, 0)}"
  }
}

data "template_file" "quorum_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(var.quorum_vpc_cidr, 1, 0)}"
  }
}

data "template_file" "bootnode_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(var.quorum_vpc_cidr, 1, 1)}"
  }
}

data "template_file" "quorum_maker_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(data.template_file.quorum_cidr_block.rendered, 3, 0)}"
  }
}

data "template_file" "quorum_validator_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(data.template_file.quorum_cidr_block.rendered, 3, 1)}"
  }
}

data "template_file" "quorum_observer_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(data.template_file.quorum_cidr_block.rendered, 3, 2)}"
  }
}

data "template_file" "efs_mt_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(data.template_file.quorum_cidr_block.rendered, 3, 3)}"
  }
}

data "template_file" "quorum_backup_lambda_private_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(data.template_file.quorum_cidr_block.rendered, 3, 4)}"
  }
}

data "template_file" "quorum_backup_lambda_public_cidr_block" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(data.template_file.quorum_cidr_block.rendered, 3, 5)}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# EFS File System
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "efs" {
  count = "${var.use_efs ? lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) > 0 ? lookup(var.az_override, var.aws_region, "") == "" ? length(data.aws_availability_zones.available.names) : length(split(",", lookup(var.az_override, var.aws_region, ""))) : 0 : 0}"

  vpc_id            = "${aws_vpc.quorum_cluster.id}"
  availability_zone = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(coalescelist(split("," ,lookup(var.az_override, var.aws_region, "")), list("")), count.index)}"
  cidr_block        = "${cidrsubnet(data.template_file.efs_mt_cidr_block.rendered, 3, count.index)}"
}

resource "aws_efs_file_system" "chain_data" {
  count = "${var.use_efs ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)) : 0}"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags {
    Name = "chain-data-net-${var.network_id}-${var.aws_region}"
  }
}

resource "aws_efs_mount_target" "chain_data" {
  # One mount target per subnet
  count = "${var.use_efs ? lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) > 0 ? lookup(var.az_override, var.aws_region, "") == "" ? length(data.aws_availability_zones.available.names) : length(split(",", lookup(var.az_override, var.aws_region, ""))) : 0 : 0}"

  file_system_id  = "${aws_efs_file_system.chain_data.id}"
  subnet_id       = "${element(aws_subnet.efs.*.id, count.index)}"
  security_groups = ["${aws_security_group.efs.id}"]
}
