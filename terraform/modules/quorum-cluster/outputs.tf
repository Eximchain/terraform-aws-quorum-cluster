output "quorum_maker_node_dns" {
  value = "${module.quorum_cluster_us_east_1.quorum_maker_node_dns}"
}

output "quorum_validator_node_dns" {
  value = "${module.quorum_cluster_us_east_1.quorum_validator_node_dns}"
}

output "quorum_observer_node_dns" {
  value = "${module.quorum_cluster_us_east_1.quorum_observer_node_dns}"
}

output "bootnode_dns" {
  value = "${module.quorum_cluster_us_east_1.bootnode_dns}"
}

output "vault_server_ips" {
  value = "${module.quorum_vault.vault_server_public_ips}"
}
