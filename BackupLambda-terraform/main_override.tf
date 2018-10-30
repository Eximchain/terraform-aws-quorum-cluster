# This file is to be placed in the main Terraform directory
module "quorum_cluster" {
  private_key_path         = "${var.private_key_path}"
}

output "private_key_path" {
   value = "${var.private_key_path}"
}

output "quorum_cluster_private_key_path" {
   value = "${var.private_key_path}"
}