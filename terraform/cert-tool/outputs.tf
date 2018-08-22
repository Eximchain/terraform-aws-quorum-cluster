output "ca_public_key_file_path" {
  value = "${module.cert_tool.ca_public_key_file_path}"
}

output "public_key_file_path" {
  value = "${module.cert_tool.public_key_file_path}"
}

output "private_key_file_path" {
  value = "${module.cert_tool.private_key_file_path}"
}

output "server_cert_arn" {
  value = "${module.cert_tool.server_cert_arn}"
}

output "kms_key_id" {
  value = "${module.cert_tool.kms_key_id}"
}

output "kms_key_arn" {
  value = "${module.cert_tool.kms_key_arn}"
}
