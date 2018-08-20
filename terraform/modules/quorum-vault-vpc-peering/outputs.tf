#output "vault_to_quorum_peering_connection_ids" {
#  value = "${zipmap(aws_vpc_peering_connection.vault_to_quorum.*.peer_region, aws_vpc_peering_connection.vault_to_quorum.*.id)}"
#}

#output "vault_to_bootnode_peering_connection_ids" {
#  value = "${zipmap(aws_vpc_peering_connection.vault_to_bootnode.*.peer_region, aws_vpc_peering_connection.vault_to_bootnode.*.id)}"
#}
