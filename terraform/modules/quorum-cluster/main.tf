# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.9.3"
}

provider "aws" {
  region = "${var.primary_region}"
}

provider "template" {
  version = "~> 1.0"
}

provider "local" {
  version = "~> 1.1"
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKUP S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "data_backup" {
  bucket_prefix = "quorum-net-${var.network_id}-backup-"
  force_destroy = "${var.force_destroy_s3_buckets}"

  versioning {
    enabled = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PUBLIC KEY FILE IF USED
# ---------------------------------------------------------------------------------------------------------------------
data "local_file" "public_key" {
  count = "${var.public_key == "" ? 1 : 0}"

  filename = "${var.public_key_path}"
}

# ---------------------------------------------------------------------------------------------------------------------
# VAULT CLUSTER FOR USE WITH QUORUM
# ---------------------------------------------------------------------------------------------------------------------
module "quorum_vault" {
  source = "../quorum-vault"

  public_key = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  aws_region    = "${var.primary_region}"
  vault_port    = "${var.vault_port}"
  network_id    = "${var.network_id}"

  force_destroy_s3_bucket = "${var.force_destroy_s3_buckets}"

  ssh_ips = "${var.ssh_ips}"

  bootnode_vpc_base_cidr = "${var.bootnode_vpc_base_cidr}"
  quorum_vpc_base_cidr   = "${var.quorum_vpc_base_cidr}"

  vault_cluster_size   = "${var.vault_cluster_size}"
  vault_instance_type  = "${var.vault_instance_type}"
  consul_cluster_size  = "${var.consul_cluster_size}"
  consul_instance_type = "${var.consul_instance_type}"

  use_dedicated_vault_servers  = "${var.use_dedicated_vault_servers}"
  use_dedicated_consul_servers = "${var.use_dedicated_consul_servers}"

  vault_consul_ami = "${var.vault_consul_ami}"

  cert_tool_ca_public_key           = "${var.cert_tool_ca_public_key}"
  cert_tool_public_key              = "${var.cert_tool_public_key}"
  cert_tool_private_key_base64      = "${var.cert_tool_private_key_base64}"
  cert_tool_ca_public_key_file_path = "${var.cert_tool_ca_public_key_file_path}"
  cert_tool_public_key_file_path    = "${var.cert_tool_public_key_file_path}"
  cert_tool_private_key_file_path   = "${var.cert_tool_private_key_file_path}"

  cert_tool_kms_key_id      = "${var.cert_tool_kms_key_id}"
  cert_tool_server_cert_arn = "${var.cert_tool_server_cert_arn}"

  bootnode_counts       = "${var.bootnode_counts}"
  maker_node_counts     = "${var.maker_node_counts}"
  validator_node_counts = "${var.validator_node_counts}"
  observer_node_counts  = "${var.observer_node_counts}"

  threatstack_deploy_key       = "${var.threatstack_deploy_key}"
  vault_enterprise_license_key = "${var.vault_enterprise_license_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM CLUSTER FOR EACH REGION
# ---------------------------------------------------------------------------------------------------------------------
module "quorum_cluster_us_east_1" {
  source = "../quorum-cluster-region"

  aws_region = "us-east-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 0)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 0)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "us-east-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "us-east-1", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 1)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 1)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "us-east-2", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "us-east-2", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 2)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 2)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "us-west-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "us-west-1", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 3)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 3)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "us-west-2", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "us-west-2", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 4)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 4)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "eu-central-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "eu-central-1", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 5)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 5)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "eu-west-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "eu-west-1", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 6)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 6)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "eu-west-2", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "eu-west-2", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 7)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 7)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "ap-south-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "ap-south-1", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 8)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 8)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "ap-northeast-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "ap-northeast-1", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 9)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 9)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "ap-northeast-2", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "ap-northeast-2", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 10)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 10)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "ap-southeast-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "ap-southeast-1", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 11)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 11)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "ap-southeast-2", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "ap-southeast-2", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 12)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 12)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "ca-central-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "ca-central-1", "")}"

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

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  generate_metrics         = "${var.generate_metrics}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"
  private_key = "${var.private_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_maker_instance_type}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 13)}"
  bootnode_vpc_cidr = "${cidrsubnet(var.bootnode_vpc_base_cidr, 5, 13)}"

  node_volume_size = "${var.node_volume_size}"

  threatstack_deploy_key = "${var.threatstack_deploy_key}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  quorum_ami   = "${lookup(var.quorum_amis, "sa-east-1", "")}"
  bootnode_ami = "${lookup(var.bootnode_amis, "sa-east-1", "")}"

  bootnode_counts       = "${var.bootnode_counts}"
  maker_node_counts     = "${var.maker_node_counts}"
  validator_node_counts = "${var.validator_node_counts}"
  observer_node_counts  = "${var.observer_node_counts}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Peering connections between the vault VPC and other VPCs
# ---------------------------------------------------------------------------------------------------------------------
module "vault_vpc_peering_connections" {
  source = "../quorum-vault-vpc-peering"

  network_id     = "${var.network_id}"
  primary_region = "${var.primary_region}"

  quorum_vault_vpc_id = "${module.quorum_vault.vpc_id}"

  quorum_vpc_base_cidr   = "${var.quorum_vpc_base_cidr}"
  bootnode_vpc_base_cidr = "${var.bootnode_vpc_base_cidr}"

  quorum_vpcs {
    us-east-1      = "${module.quorum_cluster_us_east_1.quorum_vpc_id}"
    us-east-2      = "${module.quorum_cluster_us_east_2.quorum_vpc_id}"
    us-west-1      = "${module.quorum_cluster_us_west_1.quorum_vpc_id}"
    us-west-2      = "${module.quorum_cluster_us_west_2.quorum_vpc_id}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.quorum_vpc_id}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.quorum_vpc_id}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.quorum_vpc_id}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.quorum_vpc_id}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.quorum_vpc_id}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.quorum_vpc_id}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.quorum_vpc_id}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.quorum_vpc_id}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.quorum_vpc_id}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.quorum_vpc_id}"
  }

  quorum_vpc_peering_counts {
    us-east-1      = "${signum(lookup(var.maker_node_counts, "us-east-1", 0) + lookup(var.validator_node_counts, "us-east-1", 0) + lookup(var.observer_node_counts, "us-east-1", 0))}"
    us-east-2      = "${signum(lookup(var.maker_node_counts, "us-east-2", 0) + lookup(var.validator_node_counts, "us-east-2", 0) + lookup(var.observer_node_counts, "us-east-2", 0))}"
    us-west-1      = "${signum(lookup(var.maker_node_counts, "us-west-1", 0) + lookup(var.validator_node_counts, "us-west-1", 0) + lookup(var.observer_node_counts, "us-west-1", 0))}"
    us-west-2      = "${signum(lookup(var.maker_node_counts, "us-west-2", 0) + lookup(var.validator_node_counts, "us-west-2", 0) + lookup(var.observer_node_counts, "us-west-2", 0))}"
    eu-central-1   = "${signum(lookup(var.maker_node_counts, "eu-central-1", 0) + lookup(var.validator_node_counts, "eu-central-1", 0) + lookup(var.observer_node_counts, "eu-central-1", 0))}"
    eu-west-1      = "${signum(lookup(var.maker_node_counts, "eu-west-1", 0) + lookup(var.validator_node_counts, "eu-west-1", 0) + lookup(var.observer_node_counts, "eu-west-1", 0))}"
    eu-west-2      = "${signum(lookup(var.maker_node_counts, "eu-west-2", 0) + lookup(var.validator_node_counts, "eu-west-2", 0) + lookup(var.observer_node_counts, "eu-west-2", 0))}"
    ap-south-1     = "${signum(lookup(var.maker_node_counts, "ap-south-1", 0) + lookup(var.validator_node_counts, "ap-south-1", 0) + lookup(var.observer_node_counts, "ap-south-1", 0))}"
    ap-northeast-1 = "${signum(lookup(var.maker_node_counts, "ap-northeast-1", 0) + lookup(var.validator_node_counts, "ap-northeast-1", 0) + lookup(var.observer_node_counts, "ap-northeast-1", 0))}"
    ap-northeast-2 = "${signum(lookup(var.maker_node_counts, "ap-northeast-2", 0) + lookup(var.validator_node_counts, "ap-northeast-2", 0) + lookup(var.observer_node_counts, "ap-northeast-2", 0))}"
    ap-southeast-1 = "${signum(lookup(var.maker_node_counts, "ap-southeast-1", 0) + lookup(var.validator_node_counts, "ap-southeast-1", 0) + lookup(var.observer_node_counts, "ap-southeast-1", 0))}"
    ap-southeast-2 = "${signum(lookup(var.maker_node_counts, "ap-southeast-2", 0) + lookup(var.validator_node_counts, "ap-southeast-2", 0) + lookup(var.observer_node_counts, "ap-southeast-2", 0))}"
    ca-central-1   = "${signum(lookup(var.maker_node_counts, "ca-central-1", 0) + lookup(var.validator_node_counts, "ca-central-1", 0) + lookup(var.observer_node_counts, "ca-central-1", 0))}"
    sa-east-1      = "${signum(lookup(var.maker_node_counts, "sa-east-1", 0) + lookup(var.validator_node_counts, "sa-east-1", 0) + lookup(var.observer_node_counts, "sa-east-1", 0))}"
  }

  bootnode_vpcs {
    us-east-1      = "${module.quorum_cluster_us_east_1.bootnode_vpc_id}"
    us-east-2      = "${module.quorum_cluster_us_east_2.bootnode_vpc_id}"
    us-west-1      = "${module.quorum_cluster_us_west_1.bootnode_vpc_id}"
    us-west-2      = "${module.quorum_cluster_us_west_2.bootnode_vpc_id}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.bootnode_vpc_id}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.bootnode_vpc_id}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.bootnode_vpc_id}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.bootnode_vpc_id}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.bootnode_vpc_id}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.bootnode_vpc_id}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.bootnode_vpc_id}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.bootnode_vpc_id}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.bootnode_vpc_id}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.bootnode_vpc_id}"
  }

  bootnode_vpc_peering_counts {
    us-east-1      = "${signum(lookup(var.bootnode_counts, "us-east-1", 0))}"
    us-east-2      = "${signum(lookup(var.bootnode_counts, "us-east-2", 0))}"
    us-west-1      = "${signum(lookup(var.bootnode_counts, "us-west-1", 0))}"
    us-west-2      = "${signum(lookup(var.bootnode_counts, "us-west-2", 0))}"
    eu-central-1   = "${signum(lookup(var.bootnode_counts, "eu-central-1", 0))}"
    eu-west-1      = "${signum(lookup(var.bootnode_counts, "eu-west-1", 0))}"
    eu-west-2      = "${signum(lookup(var.bootnode_counts, "eu-west-2", 0))}"
    ap-south-1     = "${signum(lookup(var.bootnode_counts, "ap-south-1", 0))}"
    ap-northeast-1 = "${signum(lookup(var.bootnode_counts, "ap-northeast-1", 0))}"
    ap-northeast-2 = "${signum(lookup(var.bootnode_counts, "ap-northeast-2", 0))}"
    ap-southeast-1 = "${signum(lookup(var.bootnode_counts, "ap-southeast-1", 0))}"
    ap-southeast-2 = "${signum(lookup(var.bootnode_counts, "ap-southeast-2", 0))}"
    ca-central-1   = "${signum(lookup(var.bootnode_counts, "ca-central-1", 0))}"
    sa-east-1      = "${signum(lookup(var.bootnode_counts, "sa-east-1", 0))}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Network Internal DNS Service
# ---------------------------------------------------------------------------------------------------------------------
module "internal_dns" {
  source = "../internal-dns"

  network_id     = "${var.network_id}"
  primary_vpc    = "${module.quorum_vault.vpc_id}"

  vault_lb_dns_name = "${module.quorum_vault.vault_dns}"
  vault_lb_zone_id  = "${module.quorum_vault.vault_lb_zone_id}"

  root_domain      = "${var.internal_dns_root_domain}"
  sub_domain_vault = "${var.internal_dns_sub_domain_vault}"

  quorum_vpcs {
    us-east-1      = "${module.quorum_cluster_us_east_1.quorum_vpc_id}"
    us-east-2      = "${module.quorum_cluster_us_east_2.quorum_vpc_id}"
    us-west-1      = "${module.quorum_cluster_us_west_1.quorum_vpc_id}"
    us-west-2      = "${module.quorum_cluster_us_west_2.quorum_vpc_id}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.quorum_vpc_id}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.quorum_vpc_id}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.quorum_vpc_id}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.quorum_vpc_id}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.quorum_vpc_id}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.quorum_vpc_id}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.quorum_vpc_id}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.quorum_vpc_id}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.quorum_vpc_id}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.quorum_vpc_id}"
  }

  quorum_vpc_association_counts {
    us-east-1      = "${signum(lookup(var.maker_node_counts, "us-east-1", 0) + lookup(var.validator_node_counts, "us-east-1", 0) + lookup(var.observer_node_counts, "us-east-1", 0))}"
    us-east-2      = "${signum(lookup(var.maker_node_counts, "us-east-2", 0) + lookup(var.validator_node_counts, "us-east-2", 0) + lookup(var.observer_node_counts, "us-east-2", 0))}"
    us-west-1      = "${signum(lookup(var.maker_node_counts, "us-west-1", 0) + lookup(var.validator_node_counts, "us-west-1", 0) + lookup(var.observer_node_counts, "us-west-1", 0))}"
    us-west-2      = "${signum(lookup(var.maker_node_counts, "us-west-2", 0) + lookup(var.validator_node_counts, "us-west-2", 0) + lookup(var.observer_node_counts, "us-west-2", 0))}"
    eu-central-1   = "${signum(lookup(var.maker_node_counts, "eu-central-1", 0) + lookup(var.validator_node_counts, "eu-central-1", 0) + lookup(var.observer_node_counts, "eu-central-1", 0))}"
    eu-west-1      = "${signum(lookup(var.maker_node_counts, "eu-west-1", 0) + lookup(var.validator_node_counts, "eu-west-1", 0) + lookup(var.observer_node_counts, "eu-west-1", 0))}"
    eu-west-2      = "${signum(lookup(var.maker_node_counts, "eu-west-2", 0) + lookup(var.validator_node_counts, "eu-west-2", 0) + lookup(var.observer_node_counts, "eu-west-2", 0))}"
    ap-south-1     = "${signum(lookup(var.maker_node_counts, "ap-south-1", 0) + lookup(var.validator_node_counts, "ap-south-1", 0) + lookup(var.observer_node_counts, "ap-south-1", 0))}"
    ap-northeast-1 = "${signum(lookup(var.maker_node_counts, "ap-northeast-1", 0) + lookup(var.validator_node_counts, "ap-northeast-1", 0) + lookup(var.observer_node_counts, "ap-northeast-1", 0))}"
    ap-northeast-2 = "${signum(lookup(var.maker_node_counts, "ap-northeast-2", 0) + lookup(var.validator_node_counts, "ap-northeast-2", 0) + lookup(var.observer_node_counts, "ap-northeast-2", 0))}"
    ap-southeast-1 = "${signum(lookup(var.maker_node_counts, "ap-southeast-1", 0) + lookup(var.validator_node_counts, "ap-southeast-1", 0) + lookup(var.observer_node_counts, "ap-southeast-1", 0))}"
    ap-southeast-2 = "${signum(lookup(var.maker_node_counts, "ap-southeast-2", 0) + lookup(var.validator_node_counts, "ap-southeast-2", 0) + lookup(var.observer_node_counts, "ap-southeast-2", 0))}"
    ca-central-1   = "${signum(lookup(var.maker_node_counts, "ca-central-1", 0) + lookup(var.validator_node_counts, "ca-central-1", 0) + lookup(var.observer_node_counts, "ca-central-1", 0))}"
    sa-east-1      = "${signum(lookup(var.maker_node_counts, "sa-east-1", 0) + lookup(var.validator_node_counts, "sa-east-1", 0) + lookup(var.observer_node_counts, "sa-east-1", 0))}"
  }

  bootnode_vpcs {
    us-east-1      = "${module.quorum_cluster_us_east_1.bootnode_vpc_id}"
    us-east-2      = "${module.quorum_cluster_us_east_2.bootnode_vpc_id}"
    us-west-1      = "${module.quorum_cluster_us_west_1.bootnode_vpc_id}"
    us-west-2      = "${module.quorum_cluster_us_west_2.bootnode_vpc_id}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.bootnode_vpc_id}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.bootnode_vpc_id}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.bootnode_vpc_id}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.bootnode_vpc_id}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.bootnode_vpc_id}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.bootnode_vpc_id}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.bootnode_vpc_id}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.bootnode_vpc_id}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.bootnode_vpc_id}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.bootnode_vpc_id}"
  }

  bootnode_vpc_association_counts {
    us-east-1      = "${signum(lookup(var.bootnode_counts, "us-east-1", 0))}"
    us-east-2      = "${signum(lookup(var.bootnode_counts, "us-east-2", 0))}"
    us-west-1      = "${signum(lookup(var.bootnode_counts, "us-west-1", 0))}"
    us-west-2      = "${signum(lookup(var.bootnode_counts, "us-west-2", 0))}"
    eu-central-1   = "${signum(lookup(var.bootnode_counts, "eu-central-1", 0))}"
    eu-west-1      = "${signum(lookup(var.bootnode_counts, "eu-west-1", 0))}"
    eu-west-2      = "${signum(lookup(var.bootnode_counts, "eu-west-2", 0))}"
    ap-south-1     = "${signum(lookup(var.bootnode_counts, "ap-south-1", 0))}"
    ap-northeast-1 = "${signum(lookup(var.bootnode_counts, "ap-northeast-1", 0))}"
    ap-northeast-2 = "${signum(lookup(var.bootnode_counts, "ap-northeast-2", 0))}"
    ap-southeast-1 = "${signum(lookup(var.bootnode_counts, "ap-southeast-1", 0))}"
    ap-southeast-2 = "${signum(lookup(var.bootnode_counts, "ap-southeast-2", 0))}"
    ca-central-1   = "${signum(lookup(var.bootnode_counts, "ca-central-1", 0))}"
    sa-east-1      = "${signum(lookup(var.bootnode_counts, "sa-east-1", 0))}"
  }
}
