# ---------------------------------------------------------------------------------------------------------------------
# PROVIDER REQUIRED VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
provider "tls" {
  version = "~> 1.0"
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
    "Resource": ["${var.vault_cert_bucket_arn}"]
  },{
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource": [
      "${var.vault_cert_bucket_arn}/ca.crt.pem",
      "${var.vault_cert_bucket_arn}/vault.crt.pem"
    ]
  }]
}
EOF
}
