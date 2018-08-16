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
  value = "${aws_autoscaling_group.vault_cluster.name}"
}

output "vault_cluster_size" {
  value = "${aws_autoscaling_group.vault_cluster.desired_capacity}"
}

output "vault_iam_role_id" {
  value = "${aws_iam_role.vault_cluster.id}"
}

output "vault_iam_role_arn" {
  value = "${aws_iam_role.vault_cluster.arn}"
}

output "vault_security_group_id" {
  value = "${aws_security_group.vault_cluster.id}"
}

output "vault_launch_config_name" {
  value = "${aws_launch_configuration.vault_cluster.name}"
}

output "vault_cluster_tag_key" {
  value = "Name"
}

output "vault_cluster_tag_value" {
  value = "${data.template_file.vault_cluster_name.rendered}"
}

output "consul_asg_name" {
  value = "${aws_autoscaling_group.consul_cluster.name}"
}

output "consul_cluster_size" {
  value = "${aws_autoscaling_group.consul_cluster.desired_capacity}"
}

output "consul_iam_role_id" {
  value = "${aws_iam_role.consul_cluster.id}"
}

output "consul_iam_role_arn" {
  value = "${aws_iam_role.consul_cluster.arn}"
}

output "consul_security_group_id" {
  value = "${aws_security_group.consul_cluster.id}"
}

output "consul_launch_config_name" {
  value = "${aws_launch_configuration.consul_cluster.name}"
}

output "consul_cluster_tag_key" {
  value = "${data.template_file.consul_cluster_tag_key.rendered}"
}

output "consul_cluster_tag_value" {
  value = "${data.template_file.consul_cluster_tag_value.rendered}"
}

output "vault_cert_s3_upload_id" {
  value = "${null_resource.vault_cert_s3_upload.id}"
}
