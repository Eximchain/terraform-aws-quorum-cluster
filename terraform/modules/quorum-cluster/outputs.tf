output "quorum_maker_node_ips" {
  value = "${aws_instance.quorum_maker_node.*.public_ip}"
}

output "quorum_validator_node_ips" {
  value = "${aws_instance.quorum_validator_node.*.public_ip}"
}

output "quorum_observer_node_ips" {
  value = "${aws_instance.quorum_observer_node.*.public_ip}"
}

output "bootnode_ips" {
  value = "${aws_instance.bootnode.*.public_ip}"
}

output "vault_server_ips" {
  value = "${data.aws_instances.vault_servers.public_ips}"
}
