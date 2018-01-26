output "quorum_maker_node_dns" {
  value = "${aws_instance.quorum_maker_node.*.public_dns}"
}

output "quorum_validator_node_dns" {
  value = "${aws_instance.quorum_validator_node.*.public_dns}"
}

output "quorum_observer_node_dns" {
  value = "${aws_instance.quorum_observer_node.*.public_dns}"
}

output "bootnode_dns" {
  value = "${aws_instance.bootnode.*.public_dns}"
}
