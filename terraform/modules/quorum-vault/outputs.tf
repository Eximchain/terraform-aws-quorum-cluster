output "vault_server_public_ips" {
  value = "${data.aws_instances.vault_servers.public_ips}"
}

output "vault_dns" {
  value = "${aws_lb.quorum_vault.dns_name}"
}

output "vault_port" {
  value = "${var.vault_port}"
}

output "vault_cert_bucket_name" {
  value = "${aws_s3_bucket.vault_certs.bucket}"
}

output "vault_cert_bucket_arn" {
  value = "${aws_s3_bucket.vault_certs.arn}"
}

output "vault_asg_name" {
  value = "${module.vault_cluster.asg_name}"
}

output "vault_cluster_size" {
  value = "${module.vault_cluster.cluster_size}"
}

output "vault_iam_role_id" {
  value = "${module.vault_cluster.iam_role_id}"
}

output "vault_iam_role_arn" {
  value = "${module.vault_cluster.iam_role_arn}"
}

output "vault_security_group_id" {
  value = "${module.vault_cluster.security_group_id}"
}

output "vault_launch_config_name" {
  value = "${module.vault_cluster.launch_config_name}"
}

output "vault_cluster_tag_key" {
  value = "${module.vault_cluster.cluster_tag_key}"
}

output "vault_cluster_tag_value" {
  value = "${module.vault_cluster.cluster_tag_value}"
}

output "consul_asg_name" {
  value = "${module.consul_cluster.asg_name}"
}

output "consul_cluster_size" {
  value = "${module.consul_cluster.cluster_size}"
}

output "consul_iam_role_id" {
  value = "${module.consul_cluster.iam_role_id}"
}

output "consul_iam_role_arn" {
  value = "${module.consul_cluster.iam_role_arn}"
}

output "consul_security_group_id" {
  value = "${module.consul_cluster.security_group_id}"
}

output "consul_launch_config_name" {
  value = "${module.consul_cluster.launch_config_name}"
}

output "consul_cluster_tag_key" {
  value = "${module.consul_cluster.cluster_tag_key}"
}

output "consul_cluster_tag_value" {
  value = "${module.consul_cluster.cluster_tag_value}"
}

output "vault_cert_s3_upload_id" {
  value = "${null_resource.vault_cert_s3_upload.id}"
}
