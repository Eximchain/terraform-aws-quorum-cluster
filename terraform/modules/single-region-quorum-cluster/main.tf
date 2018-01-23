# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.9.3"
}

provider "aws" {
  version = "~> 1.5"

  region  = "${var.aws_region}"
}

provider "template" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY PAIR FOR ALL INSTANCES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_key_pair" "auth" {
  key_name   = "quorum-cluster-${var.network_id}"
  public_key = "${file(var.public_key_path)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# S3FS BUCKET FOR CONSTELLATION PAYLOADS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "quorum_constellation" {
  bucket_prefix = "quorum-constellation-network-${var.network_id}-"
  force_destroy = "${var.force_destroy_s3_buckets}"
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE AND BOOTNODE POLICY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "quorum" {
  name        = "quorum-policy-network-${var.network_id}"
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
    "Action": ["s3:*"],
    "Resource": [
      "${aws_s3_bucket.quorum_constellation.arn}",
      "${aws_s3_bucket.quorum_constellation.arn}/*"
    ]
  },{
    "Effect": "Allow",
    "Action": ["s3:ListBucket"],
    "Resource": ["${aws_s3_bucket.vault_certs.arn}"]
  },{
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource": [
      "${aws_s3_bucket.vault_certs.arn}/ca.crt.pem",
      "${aws_s3_bucket.vault_certs.arn}/vault.crt.pem"
    ]
  }]
}
EOF
}
