output "quorum_maker_node_dns" {
  value = "${data.aws_instance.quorum_maker_node.*.public_dns}"
}

output "quorum_validator_node_dns" {
  value = "${data.aws_instance.quorum_validator_node.*.public_dns}"
}

output "quorum_observer_node_dns" {
  value = "${data.aws_instance.quorum_observer_node.*.public_dns}"
}

output "bootnode_ips" {
  value = "${coalescelist(aws_eip.bootnodes.*.public_ip, data.aws_instance.bootnodes.*.public_ip)}"
}