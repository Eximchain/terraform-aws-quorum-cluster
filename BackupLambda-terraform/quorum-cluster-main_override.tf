# This file must be placed in the quorum-cluster directory

data "local_file" "private_key" {
  count = "${var.private_key == "" ? 1 : 0}"

  filename = "${var.private_key_path}"
}


// Merged into the quorum_vault in quorum-cluster
// module "quorum_vault" {
//   private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
// }

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM CLUSTER OVERRIDES FOR EACH REGION
# ---------------------------------------------------------------------------------------------------------------------
module "quorum_cluster_us_east_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_us_east_2" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_us_west_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_us_west_2" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_eu_central_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_eu_west_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_eu_west_2" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_ap_south_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_ap_northeast_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_ap_northeast_2" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_ap_southeast_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_ap_southeast_2" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_ca_central_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

module "quorum_cluster_sa_east_1" {
  private_key = "${var.private_key == "" ? join("", data.local_file.private_key.*.content) : var.private_key}"
}

# Override the module definition, and add variable named quorum_vpc_main_route_table
module "vpc_peering_connections" {
  quorum_vpc_main_route_table = {
    us-east-1      = "${module.quorum_cluster_us_east_1.quorum_cluster_main_route_table_id}"
    us-east-2      = "${module.quorum_cluster_us_east_2.quorum_cluster_main_route_table_id}"
    us-west-1      = "${module.quorum_cluster_us_west_1.quorum_cluster_main_route_table_id}"
    us-west-2      = "${module.quorum_cluster_us_west_2.quorum_cluster_main_route_table_id}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.quorum_cluster_main_route_table_id}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.quorum_cluster_main_route_table_id}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.quorum_cluster_main_route_table_id}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.quorum_cluster_main_route_table_id}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.quorum_cluster_main_route_table_id}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.quorum_cluster_main_route_table_id}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.quorum_cluster_main_route_table_id}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.quorum_cluster_main_route_table_id}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.quorum_cluster_main_route_table_id}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.quorum_cluster_main_route_table_id}"
  }
}