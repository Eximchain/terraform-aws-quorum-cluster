output "quorum_maker_node_dns" {
  value = "${module.quorum_cluster.quorum_maker_node_dns}"
}

output "quorum_validator_node_dns" {
  value = "${module.quorum_cluster.quorum_validator_node_dns}"
}

output "quorum_observer_node_dns" {
  value = "${module.quorum_cluster.quorum_observer_node_dns}"
}

output "bootnode_ips" {
  value = "${module.quorum_cluster.bootnode_ips}"
}

output "vault_server_ips" {
  value = "${module.quorum_cluster.vault_server_ips}"
}
