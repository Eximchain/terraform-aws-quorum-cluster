output "quorum_cluster_main_route_table_id" {
  value = "${length(aws_vpc.quorum_cluster.*.id) != 0 ? element(concat(aws_vpc.quorum_cluster.*.main_route_table_id, list("")), 0) : ""}"
}