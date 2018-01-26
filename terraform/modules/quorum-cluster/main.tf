# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.9.3"
}

provider "aws" {
  version = "~> 1.5"

  region  = "us-east-1"
}

provider "template" {
  version = "~> 1.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY PAIR FOR ALL INSTANCES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_key_pair" "auth" {
  key_name   = "quorum-cluster-${var.network_id}"
  public_key = "${file(var.public_key_path)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# VAULT CLUSTER FOR USE WITH QUORUM
# ---------------------------------------------------------------------------------------------------------------------
module "quorum_vault" {
  source = "../quorum-vault"

  vault_amis      = "${var.vault_amis}"
  cert_owner      = "${var.cert_owner}"
  aws_key_pair_id = "${aws_key_pair.auth.id}"

  aws_region    = "${var.vault_region}"
  aws_azs       = "${var.aws_azs}"
  vault_port    = "${var.vault_port}"
  network_id    = "${var.network_id}"
  cert_org_name = "${var.cert_org_name}"

  force_destroy_s3_bucket = "${var.force_destroy_s3_buckets}"

  vault_cluster_size   = "${var.vault_cluster_size}"
  vault_instance_type  = "${var.vault_instance_type}"
  consul_cluster_size  = "${var.consul_cluster_size}"
  consul_instance_type = "${var.consul_instance_type}"
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM CLUSTER FOR EACH REGION
# ---------------------------------------------------------------------------------------------------------------------
module "quorum_cluster_us_east_1" {
  source = "../quorum-cluster-region"

  aws_region = "us-east-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  aws_key_pair_id = "${aws_key_pair.auth.id}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  aws_azs = "${var.aws_azs}"

  bootnode_instance_type    = "${var.bootnode_instance_type}"
  quorum_node_instance_type = "${var.quorum_node_instance_type}"

  quorum_amis   = "${var.quorum_amis}"
  bootnode_amis = "${var.bootnode_amis}"

  bootnode_counts       = "${var.bootnode_counts}"
  maker_node_counts     = "${var.maker_node_counts}"
  validator_node_counts = "${var.validator_node_counts}"
  observer_node_counts  = "${var.observer_node_counts}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
}
