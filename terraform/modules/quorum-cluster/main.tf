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
# PUBLIC KEY FILE IF USED
# ---------------------------------------------------------------------------------------------------------------------
data "local_file" "public_key" {
  count = "${var.public_key == "" ? 1 : 0}"

  filename = "${var.public_key_path}"
}

data "local_file" "backup_lambda_ssh_private_key" {
  count = "${var.backup_enabled && var.backup_lambda_ssh_private_key == "" ? 1 : 0}"

  filename = "${var.backup_lambda_ssh_private_key_path}"
}

# ---------------------------------------------------------------------------------------------------------------------
# S3 NODE COUNTS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "quorum_node_counts" {
  bucket = "quorum-node-counts-network-${var.network_id}${var.s3_bucket_suffix}"

  force_destroy = "${var.force_destroy_s3_buckets}"
}

resource "aws_s3_bucket_object" "bootnode_counts" {
  key                    = "bootnode-counts.json"
  bucket                 = "${aws_s3_bucket.quorum_node_counts.bucket}"
  content                = "${data.template_file.bootnode_count_json.rendered}"
  server_side_encryption = "aws:kms"

  lifecycle {
    # Ignore changes in the number of instances
    ignore_changes        = ["content"]
  }
}

resource "aws_s3_bucket_object" "maker_counts" {
  key                    = "maker-counts.json"
  bucket                 = "${aws_s3_bucket.quorum_node_counts.bucket}"
  content                = "${data.template_file.maker_node_count_json.rendered}"
  server_side_encryption = "aws:kms"

  lifecycle {
    # Ignore changes in the number of instances
    ignore_changes        = ["content"]
  }
}

resource "aws_s3_bucket_object" "validator_counts" {
  key                    = "validator-counts.json"
  bucket                 = "${aws_s3_bucket.quorum_node_counts.bucket}"
  content                = "${data.template_file.validator_node_count_json.rendered}"
  server_side_encryption = "aws:kms"

  lifecycle {
    # Ignore changes in the number of instances
    ignore_changes        = ["content"]
  }
}

resource "aws_s3_bucket_object" "observer_counts" {
  key                    = "observer-counts.json"
  bucket                 = "${aws_s3_bucket.quorum_node_counts.bucket}"
  content                = "${data.template_file.observer_node_count_json.rendered}"
  server_side_encryption = "aws:kms"

  lifecycle {
    # Ignore changes in the number of instances
    ignore_changes        = ["content"]
  }
}

resource "null_resource" "node_counts_s3_upload" {
  depends_on = ["aws_s3_bucket_object.bootnode_counts", "aws_s3_bucket_object.maker_counts", "aws_s3_bucket_object.validator_counts", "aws_s3_bucket_object.observer_counts"]
}

# ---------------------------------------------------------------------------------------------------------------------
# NODE COUNT JSON
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" "maker_node_count_json" {
  template = "${file("${path.module}/templates/node-count.json")}"

  vars {
    ap_northeast_1_count = "${lookup(var.maker_node_counts, "ap-northeast-1", 0)}"
    ap_northeast_2_count = "${lookup(var.maker_node_counts, "ap-northeast-2", 0)}"
    ap_south_1_count     = "${lookup(var.maker_node_counts, "ap-south-1", 0)}"
    ap_southeast_1_count = "${lookup(var.maker_node_counts, "ap-southeast-1", 0)}"
    ap_southeast_2_count = "${lookup(var.maker_node_counts, "ap-southeast-2", 0)}"
    ca_central_1_count   = "${lookup(var.maker_node_counts, "ca-central-1", 0)}"
    eu_central_1_count   = "${lookup(var.maker_node_counts, "eu-central-1", 0)}"
    eu_west_1_count      = "${lookup(var.maker_node_counts, "eu-west-1", 0)}"
    eu_west_2_count      = "${lookup(var.maker_node_counts, "eu-west-2", 0)}"
    sa_east_1_count      = "${lookup(var.maker_node_counts, "sa-east-1", 0)}"
    us_east_1_count      = "${lookup(var.maker_node_counts, "us-east-1", 0)}"
    us_east_2_count      = "${lookup(var.maker_node_counts, "us-east-2", 0)}"
    us_west_1_count      = "${lookup(var.maker_node_counts, "us-west-1", 0)}"
    us_west_2_count      = "${lookup(var.maker_node_counts, "us-west-2", 0)}"
  }
}

data "template_file" "validator_node_count_json" {
  template = "${file("${path.module}/templates/node-count.json")}"

  vars {
    ap_northeast_1_count = "${lookup(var.validator_node_counts, "ap-northeast-1", 0)}"
    ap_northeast_2_count = "${lookup(var.validator_node_counts, "ap-northeast-2", 0)}"
    ap_south_1_count     = "${lookup(var.validator_node_counts, "ap-south-1", 0)}"
    ap_southeast_1_count = "${lookup(var.validator_node_counts, "ap-southeast-1", 0)}"
    ap_southeast_2_count = "${lookup(var.validator_node_counts, "ap-southeast-2", 0)}"
    ca_central_1_count   = "${lookup(var.validator_node_counts, "ca-central-1", 0)}"
    eu_central_1_count   = "${lookup(var.validator_node_counts, "eu-central-1", 0)}"
    eu_west_1_count      = "${lookup(var.validator_node_counts, "eu-west-1", 0)}"
    eu_west_2_count      = "${lookup(var.validator_node_counts, "eu-west-2", 0)}"
    sa_east_1_count      = "${lookup(var.validator_node_counts, "sa-east-1", 0)}"
    us_east_1_count      = "${lookup(var.validator_node_counts, "us-east-1", 0)}"
    us_east_2_count      = "${lookup(var.validator_node_counts, "us-east-2", 0)}"
    us_west_1_count      = "${lookup(var.validator_node_counts, "us-west-1", 0)}"
    us_west_2_count      = "${lookup(var.validator_node_counts, "us-west-2", 0)}"
  }
}

data "template_file" "observer_node_count_json" {
  template = "${file("${path.module}/templates/node-count.json")}"

  vars {
    ap_northeast_1_count = "${lookup(var.observer_node_counts, "ap-northeast-1", 0)}"
    ap_northeast_2_count = "${lookup(var.observer_node_counts, "ap-northeast-2", 0)}"
    ap_south_1_count     = "${lookup(var.observer_node_counts, "ap-south-1", 0)}"
    ap_southeast_1_count = "${lookup(var.observer_node_counts, "ap-southeast-1", 0)}"
    ap_southeast_2_count = "${lookup(var.observer_node_counts, "ap-southeast-2", 0)}"
    ca_central_1_count   = "${lookup(var.observer_node_counts, "ca-central-1", 0)}"
    eu_central_1_count   = "${lookup(var.observer_node_counts, "eu-central-1", 0)}"
    eu_west_1_count      = "${lookup(var.observer_node_counts, "eu-west-1", 0)}"
    eu_west_2_count      = "${lookup(var.observer_node_counts, "eu-west-2", 0)}"
    sa_east_1_count      = "${lookup(var.observer_node_counts, "sa-east-1", 0)}"
    us_east_1_count      = "${lookup(var.observer_node_counts, "us-east-1", 0)}"
    us_east_2_count      = "${lookup(var.observer_node_counts, "us-east-2", 0)}"
    us_west_1_count      = "${lookup(var.observer_node_counts, "us-west-1", 0)}"
    us_west_2_count      = "${lookup(var.observer_node_counts, "us-west-2", 0)}"
  }
}

data "template_file" "bootnode_count_json" {
  template = "${file("${path.module}/templates/node-count.json")}"

  vars {
    ap_northeast_1_count = "${lookup(var.bootnode_counts, "ap-northeast-1", 0)}"
    ap_northeast_2_count = "${lookup(var.bootnode_counts, "ap-northeast-2", 0)}"
    ap_south_1_count     = "${lookup(var.bootnode_counts, "ap-south-1", 0)}"
    ap_southeast_1_count = "${lookup(var.bootnode_counts, "ap-southeast-1", 0)}"
    ap_southeast_2_count = "${lookup(var.bootnode_counts, "ap-southeast-2", 0)}"
    ca_central_1_count   = "${lookup(var.bootnode_counts, "ca-central-1", 0)}"
    eu_central_1_count   = "${lookup(var.bootnode_counts, "eu-central-1", 0)}"
    eu_west_1_count      = "${lookup(var.bootnode_counts, "eu-west-1", 0)}"
    eu_west_2_count      = "${lookup(var.bootnode_counts, "eu-west-2", 0)}"
    sa_east_1_count      = "${lookup(var.bootnode_counts, "sa-east-1", 0)}"
    us_east_1_count      = "${lookup(var.bootnode_counts, "us-east-1", 0)}"
    us_east_2_count      = "${lookup(var.bootnode_counts, "us-east-2", 0)}"
    us_west_1_count      = "${lookup(var.bootnode_counts, "us-west-1", 0)}"
    us_west_2_count      = "${lookup(var.bootnode_counts, "us-west-2", 0)}"
  }
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
  s3_bucket_suffix        = "${var.s3_bucket_suffix}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  bootnode_counts       = "${var.bootnode_counts}"
  maker_node_counts     = "${var.maker_node_counts}"
  validator_node_counts = "${var.validator_node_counts}"
  observer_node_counts  = "${var.observer_node_counts}"

  threatstack_deploy_key             = "${var.threatstack_deploy_key}"
  vault_enterprise_license_key       = "${var.vault_enterprise_license_key}"
  pre_baked_vault_enterprise_license = "${var.pre_baked_vault_enterprise_license}"

  az_override = "${var.az_override}"

  okta_base_url     = "${var.okta_base_url}"
  okta_org_name     = "${var.okta_org_name}"
  okta_api_token    = "${var.okta_api_token}"
  okta_access_group = "${var.okta_access_group}"

  foxpass_base_dn   = "${var.foxpass_base_dn}"
  foxpass_bind_user = "${var.foxpass_bind_user}"
  foxpass_bind_pw   = "${var.foxpass_bind_pw}"
  foxpass_api_key   = "${var.foxpass_api_key}"

  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM CLUSTER FOR EACH REGION
# ---------------------------------------------------------------------------------------------------------------------
module "quorum_cluster_us_east_1" {
  source = "../quorum-cluster-region"

  aws_region = "us-east-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 0)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_us_east_2" {
  source = "../quorum-cluster-region"

  aws_region = "us-east-2"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 1)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_us_west_1" {
  source = "../quorum-cluster-region"

  aws_region = "us-west-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 2)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_us_west_2" {
  source = "../quorum-cluster-region"

  aws_region = "us-west-2"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 3)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_eu_central_1" {
  source = "../quorum-cluster-region"

  aws_region = "eu-central-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 4)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_eu_west_1" {
  source = "../quorum-cluster-region"

  aws_region = "eu-west-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 5)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_eu_west_2" {
  source = "../quorum-cluster-region"

  aws_region = "eu-west-2"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  # EFS not yet available in eu-west-2
  use_efs = false

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 6)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_ap_south_1" {
  source = "../quorum-cluster-region"

  aws_region = "ap-south-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  # EFS not yet available in ap-south-1
  use_efs = false

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 7)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_ap_northeast_1" {
  source = "../quorum-cluster-region"

  aws_region = "ap-northeast-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 8)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_ap_northeast_2" {
  source = "../quorum-cluster-region"

  aws_region = "ap-northeast-2"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 9)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_ap_southeast_1" {
  source = "../quorum-cluster-region"

  aws_region = "ap-southeast-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 10)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_ap_southeast_2" {
  source = "../quorum-cluster-region"

  aws_region = "ap-southeast-2"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  use_efs = "${var.use_efs}"

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 11)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_ca_central_1" {
  source = "../quorum-cluster-region"

  aws_region = "ca-central-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  # EFS not yet available in ca-central-1
  use_efs = false

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 12)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

module "quorum_cluster_sa_east_1" {
  source = "../quorum-cluster-region"

  aws_region = "sa-east-1"

  primary_region = "${var.primary_region}"

  force_destroy_s3_buckets = "${var.force_destroy_s3_buckets}"
  s3_bucket_suffix         = "${var.s3_bucket_suffix}"
  generate_metrics         = "${var.generate_metrics}"
  create_alarms            = "${var.create_alarms}"

  public_key  = "${var.public_key == "" ? join("", data.local_file.public_key.*.content) : var.public_key}"

  backup_enabled                      = "${var.backup_enabled}"
  backup_lambda_ssh_private_key       = "${var.backup_lambda_ssh_private_key == "" ? join("", data.local_file.backup_lambda_ssh_private_key.*.content) : var.backup_lambda_ssh_private_key}"
  backup_lambda_ssh_private_key_path  = "${var.backup_lambda_ssh_private_key_path}"
  backup_lambda_ssh_user              = "${var.backup_lambda_ssh_user}"
  backup_lambda_ssh_pass              = "${var.backup_lambda_ssh_pass}"
  backup_interval                     = "${var.backup_interval}"
  backup_lambda_binary                = "${var.backup_lambda_binary}"
  backup_lambda_binary_url            = "${var.backup_lambda_binary_url}"
  backup_lambda_output_path           = "${var.backup_lambda_output_path}"
  enc_ssh_path                        = "${var.enc_ssh_path}"
  enc_ssh_key                         = "${var.enc_ssh_key}"

  network_id     = "${var.network_id}"
  gas_limit      = "${var.gas_limit}"
  vote_threshold = "${var.vote_threshold}"
  min_block_time = "${var.min_block_time}"
  max_block_time = "${var.max_block_time}"
  max_peers      = "${var.max_peers}"

  vault_port = "${var.vault_port}"
  vault_dns  = "${module.internal_dns.vault_lb_fqdn}"

  vault_cert_bucket_name   = "${module.quorum_vault.vault_cert_bucket_name}"
  vault_cert_bucket_arn    = "${module.quorum_vault.vault_cert_bucket_arn}"
  consul_cluster_tag_key   = "${module.quorum_vault.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${module.quorum_vault.consul_cluster_tag_value}"

  bootnode_instance_type         = "${var.bootnode_instance_type}"
  quorum_maker_instance_type     = "${var.quorum_maker_instance_type}"
  quorum_validator_instance_type = "${var.quorum_validator_instance_type}"
  quorum_observer_instance_type  = "${var.quorum_observer_instance_type}"

  # EFS not yet available in sa-east-1
  use_efs = false

  geth_verbosity = "${var.geth_verbosity}"

  use_dedicated_bootnodes  = "${var.use_dedicated_bootnodes}"
  use_dedicated_makers     = "${var.use_dedicated_makers}"
  use_dedicated_validators = "${var.use_dedicated_validators}"
  use_dedicated_observers  = "${var.use_dedicated_observers}"

  use_elastic_bootnode_ips = "${var.use_elastic_bootnode_ips}"
  use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

  ssh_ips                        = "${var.ssh_ips}"
  other_validator_connection_ips = "${var.other_validator_connection_ips}"
  az_override                    = "${var.az_override}"

  quorum_vpc_cidr   = "${cidrsubnet(var.quorum_vpc_base_cidr, 5, 13)}"

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

  node_count_bucket_name = "${aws_s3_bucket.quorum_node_counts.bucket}"
  node_count_bucket_arn  = "${aws_s3_bucket.quorum_node_counts.arn}"

  # Quorum node user-data needs to download certificates produced by the quorum_vault module
  vault_cert_s3_upload_id = "${module.quorum_vault.vault_cert_s3_upload_id}"
  node_count_s3_upload_id = "${null_resource.node_counts_s3_upload.id}"

  quorum_maker_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_maker_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_maker_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_maker_cidr_block}"
  ]

  quorum_validator_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_validator_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_validator_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_validator_cidr_block}"
  ]

  quorum_observer_cidrs = [
    "${module.quorum_cluster_us_east_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_east_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_us_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_eu_west_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_south_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_northeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ap_southeast_2.quorum_observer_cidr_block}",
    "${module.quorum_cluster_ca_central_1.quorum_observer_cidr_block}",
    "${module.quorum_cluster_sa_east_1.quorum_observer_cidr_block}"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Peering connections between the vault VPC and other VPCs
# ---------------------------------------------------------------------------------------------------------------------
module "vpc_peering_connections" {
  source = "../quorum-vpc-peering"

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

  quorum_vpc_main_route_table {
    us-east-1      = "${module.quorum_cluster_us_east_1.quorum_vpc_main_route_table_id}"
    us-east-2      = "${module.quorum_cluster_us_east_2.quorum_vpc_main_route_table_id}"
    us-west-1      = "${module.quorum_cluster_us_west_1.quorum_vpc_main_route_table_id}"
    us-west-2      = "${module.quorum_cluster_us_west_2.quorum_vpc_main_route_table_id}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.quorum_vpc_main_route_table_id}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.quorum_vpc_main_route_table_id}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.quorum_vpc_main_route_table_id}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.quorum_vpc_main_route_table_id}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.quorum_vpc_main_route_table_id}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.quorum_vpc_main_route_table_id}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.quorum_vpc_main_route_table_id}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.quorum_vpc_main_route_table_id}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.quorum_vpc_main_route_table_id}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.quorum_vpc_main_route_table_id}"
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
}
