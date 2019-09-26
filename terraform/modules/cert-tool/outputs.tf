output "ca_public_key_file_path" {
  value = "${var.ca_public_key_file_path}"
}

output "ca_public_key" {
  value = "${tls_self_signed_cert.ca.cert_pem}"
}

output "public_key_file_path" {
  value = "${var.public_key_file_path}"
}

output "public_key" {
  value = "${tls_locally_signed_cert.cert.cert_pem}"
}

output "private_key_file_path" {
  value = "${var.private_key_file_path}"
}

output "private_key" {
  value     = "${var.use_kms_encryption ? element(concat(data.aws_kms_ciphertext.private_key.*.ciphertext_blob, list("")), 0) : tls_private_key.cert.private_key_pem}"
}

output "server_cert_arn" {
  value = "${aws_iam_server_certificate.vault_cert.arn}"
}

output "kms_key_id" {
  value = "${element(concat(aws_kms_key.private_key.*.key_id, list("")), 0)}"
}

output "kms_key_arn" {
  value = "${element(concat(aws_kms_key.private_key.*.arn, list("")), 0)}"
}
