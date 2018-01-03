output "quorum_maker_node_ips" {
  value = "${module.quorum_cluster.quorum_maker_node_ips}"
}

output "quorum_validator_node_ips" {
  value = "${module.quorum_cluster.quorum_validator_node_ips}"
}

output "quorum_observer_node_ips" {
  value = "${module.quorum_cluster.quorum_observer_node_ips}"
}

output "bootnode_ips" {
  value = "${module.quorum_cluster.bootnode_ips}"
}

output "vault_server_ips" {
  value = "${module.quorum_cluster.vault_server_ips}"
}
