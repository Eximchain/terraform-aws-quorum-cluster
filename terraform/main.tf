module "quorum_cluster" {
  # Source from github if using in another project
  source = "modules/quorum-cluster"

  # Variables sourced from terraform.tfvars
  public_key_path           = "${var.public_key_path}"
  private_key_path          = "${var.private_key_path}"
  aws_region                = "${var.aws_region}"
  network_id                = "${var.network_id}"
  force_destroy_s3_buckets  = "${var.force_destroy_s3_buckets}"
  quorum_azs                = "${var.quorum_azs}"
  vault_cluster_size        = "${var.vault_cluster_size}"
  vault_instance_type       = "${var.vault_instance_type}"
  consul_cluster_size       = "${var.consul_cluster_size}"
  consul_instance_type      = "${var.consul_instance_type}"
  bootnode_cluster_size     = "${var.bootnode_cluster_size}"
  bootnode_instance_type    = "${var.bootnode_instance_type}"
  quorum_node_instance_type = "${var.quorum_node_instance_type}"
  num_maker_nodes           = "${var.num_maker_nodes}"
  num_validator_nodes       = "${var.num_validator_nodes}"
  num_observer_nodes        = "${var.num_observer_nodes}"
  vote_threshold            = "${var.vote_threshold}"

  # AMI variables sourced from amis.auto.tfvars.json
  quorum_amis   = "${var.quorum_amis}"
  vault_amis    = "${var.vault_amis}"
  bootnode_amis = "${var.bootnode_amis}"
}
