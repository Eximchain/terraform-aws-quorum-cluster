# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.9.3"
}

provider "template" {
  version = "~> 1.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# VAULT CLUSTER FOR USE WITH QUORUM
# ---------------------------------------------------------------------------------------------------------------------
module "quorum_vault" {
  source = "../quorum-vault"

  vault_amis      = "${var.vault_amis}"
  cert_owner      = "${var.cert_owner}"
  public_key_path = "${var.public_key_path}"

  aws_region    = "${var.vault_region}"
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

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_us_east_2" {
  source = "../quorum-cluster-region"

  aws_region = "us-east-2"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_us_west_1" {
  source = "../quorum-cluster-region"

  aws_region = "us-west-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_us_west_2" {
  source = "../quorum-cluster-region"

  aws_region = "us-west-2"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_eu_central_1" {
  source = "../quorum-cluster-region"

  aws_region = "eu-central-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_eu_west_1" {
  source = "../quorum-cluster-region"

  aws_region = "eu-west-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_eu_west_2" {
  source = "../quorum-cluster-region"

  aws_region = "eu-west-2"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_ap_south_1" {
  source = "../quorum-cluster-region"

  aws_region = "ap-south-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_ap_northeast_1" {
  source = "../quorum-cluster-region"

  aws_region = "ap-northeast-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_ap_northeast_2" {
  source = "../quorum-cluster-region"

  aws_region = "ap-northeast-2"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_ap_southeast_1" {
  source = "../quorum-cluster-region"

  aws_region = "ap-southeast-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_ap_southeast_2" {
  source = "../quorum-cluster-region"

  aws_region = "ap-southeast-2"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_ca_central_1" {
  source = "../quorum-cluster-region"

  aws_region = "ca-central-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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

module "quorum_cluster_sa_east_1" {
  source = "../quorum-cluster-region"

  aws_region = "sa-east-1"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"

  public_key_path = "${var.public_key_path}"

  network_id     = "${var.network_id}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.quorum_vault.vault_dns}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

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
