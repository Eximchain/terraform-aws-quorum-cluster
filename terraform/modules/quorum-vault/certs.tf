# Certificates must exist already. They should be created by cert-tool.

# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKET FOR STORING CERTS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "vault_certs" {
  bucket_prefix = "vault-certs-network-${var.network_id}-"
  acl           = "private"
}

# ---------------------------------------------------------------------------------------------------------------------
# CERTIFICATE FILES IF USED
# ---------------------------------------------------------------------------------------------------------------------
data "local_file" "cert_tool_ca_public_key_file" {
  count = "${var.cert_tool_ca_public_key  == "" ? 1 : 0}"

  filename = "${format("%s/%s", path.module, var.cert_tool_ca_public_key_file_path)}"
}

data "local_file" "cert_tool_public_key_file" {
  count = "${var.cert_tool_public_key  == "" ? 1 : 0}"

  filename = "${format("%s/%s", path.module, var.cert_tool_public_key_file_path)}"
}

data "local_file" "cert_tool_private_key_file" {
  count = "${var.cert_tool_private_key_base64  == "" ? 1 : 0}"

  filename = "${format("%s/%s", path.module, var.cert_tool_private_key_file_path)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# UPLOAD CERTS TO S3
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_object" "vault_ca_public_key" {
  key                    = "ca.crt.pem"
  bucket                 = "${aws_s3_bucket.vault_certs.bucket}"
  content                = "${var.cert_tool_ca_public_key == "" ? join("", data.local_file.cert_tool_ca_public_key_file.*.content) : var.cert_tool_ca_public_key}"
  server_side_encryption = "aws:kms"
}

resource "aws_s3_bucket_object" "vault_public_key" {
  key                    = "vault.crt.pem"
  bucket                 = "${aws_s3_bucket.vault_certs.bucket}"
  content                = "${var.cert_tool_public_key == "" ? join("", data.local_file.cert_tool_public_key_file.*.content) : var.cert_tool_public_key}"
  server_side_encryption = "aws:kms"
}

resource "aws_s3_bucket_object" "vault_private_key" {
  key                    = "vault.key.pem.encrypted.b64"
  bucket                 = "${aws_s3_bucket.vault_certs.bucket}"
  content                = "${var.cert_tool_private_key_base64 == "" ? join("", data.local_file.cert_tool_private_key_file.*.content) : var.cert_tool_private_key_base64}"
  server_side_encryption = "aws:kms"
}

resource "null_resource" "vault_cert_s3_upload" {
  depends_on = ["aws_s3_bucket_object.vault_ca_public_key", "aws_s3_bucket_object.vault_public_key", "aws_s3_bucket_object.vault_private_key"]
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE VAULT PERMISSION TO DECRYPT KEY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_grant" "vault_decrypt_private_key" {
  key_id            = "${var.cert_tool_kms_key_id}"
  grantee_principal = "${aws_iam_role.vault_cluster.arn}"

  operations = [ "Decrypt", "DescribeKey" ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM POLICY TO ACCESS CERT BUCKET
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "vault_cert_access" {
  name        = "vault-cert-access-network-${var.network_id}"
  description = "Allow read access to the vault cert bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:ListBucket"],
    "Resource": ["${aws_s3_bucket.vault_certs.arn}"]
  },{
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource": ["${aws_s3_bucket.vault_certs.arn}/*"]
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vault_cert_access" {
  role       = "${aws_iam_role.vault_cluster.id}"
  policy_arn = "${aws_iam_policy.vault_cert_access.arn}"
}
