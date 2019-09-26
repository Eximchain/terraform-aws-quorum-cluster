# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "ca" {
  algorithm   = "${var.private_key_algorithm}"
  ecdsa_curve = "${var.private_key_ecdsa_curve}"
  rsa_bits    = "${var.private_key_rsa_bits}"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = "${tls_private_key.ca.algorithm}"
  private_key_pem   = "${tls_private_key.ca.private_key_pem}"
  is_ca_certificate = true

  validity_period_hours = "${var.validity_period_hours}"
  allowed_uses          = ["${var.ca_allowed_uses}"]

  subject {
    common_name  = "${var.ca_common_name}"
    organization = "${var.organization_name}"
  }

  # Store the CA public key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_self_signed_cert.ca.cert_pem}' > '${var.ca_public_key_file_path}' && chmod ${var.permissions} '${var.ca_public_key_file_path}' && chown ${var.owner} '${var.ca_public_key_file_path}'"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A TLS CERTIFICATE SIGNED USING THE CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "cert" {
  algorithm   = "${var.private_key_algorithm}"
  ecdsa_curve = "${var.private_key_ecdsa_curve}"
  rsa_bits    = "${var.private_key_rsa_bits}"

  # Store the certificate's private key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_private_key.cert.private_key_pem}' > '${var.private_key_file_path}' && chmod ${var.permissions} '${var.private_key_file_path}' && chown ${var.owner} '${var.private_key_file_path}'"
  }
}

resource "aws_kms_key" "private_key" {
  count = "${var.use_kms_encryption ? 1 : 0}"

  description = "Key to encrypt vault private key for quorum network ${var.network_id}"

  # 7 Days for a network we expect to be ephemeral, otherwise 30 days
  deletion_window_in_days = "${var.kms_key_deletion_window}"
}

data "aws_kms_ciphertext" "private_key" {
  count = "${var.use_kms_encryption ? 1 : 0}"

  key_id = "${aws_kms_key.private_key.key_id}"

  plaintext = "${tls_private_key.cert.private_key_pem}"
}

resource "null_resource" "overwrite_private_key_with_encryption" {
  count = "${var.use_kms_encryption ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo '${data.aws_kms_ciphertext.private_key.ciphertext_blob}' > '${var.private_key_file_path}'"
  }
}

resource "tls_cert_request" "cert" {
  key_algorithm   = "${tls_private_key.cert.algorithm}"
  private_key_pem = "${tls_private_key.cert.private_key_pem}"

  dns_names    = ["${var.dns_names}"]
  ip_addresses = ["${var.ip_addresses}"]

  subject {
    common_name  = "${var.common_name}"
    organization = "${var.organization_name}"
  }
}

resource "tls_locally_signed_cert" "cert" {
  cert_request_pem = "${tls_cert_request.cert.cert_request_pem}"

  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = "${var.validity_period_hours}"
  allowed_uses          = ["${var.allowed_uses}"]

  # Store the certificate's public key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_locally_signed_cert.cert.cert_pem}' > '${var.public_key_file_path}' && chmod ${var.permissions} '${var.public_key_file_path}' && chown ${var.owner} '${var.public_key_file_path}'"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# STORE CERTS IN IAM
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_server_certificate" "vault_cert" {
  name_prefix       = "vault-cert-network-${var.network_id}-"
  certificate_body  = "${tls_locally_signed_cert.cert.cert_pem}"
  certificate_chain = "${tls_self_signed_cert.ca.cert_pem}"
  private_key       = "${tls_private_key.cert.private_key_pem}"
}
