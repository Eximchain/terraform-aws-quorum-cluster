output "quorum_maker_node_dns" {
  value = {
    us-east-1      = "${module.quorum_cluster_us_east_1.quorum_maker_node_dns}"
    us-east-2      = "${module.quorum_cluster_us_east_2.quorum_maker_node_dns}"
    us-west-1      = "${module.quorum_cluster_us_west_1.quorum_maker_node_dns}"
    us-west-2      = "${module.quorum_cluster_us_west_2.quorum_maker_node_dns}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.quorum_maker_node_dns}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.quorum_maker_node_dns}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.quorum_maker_node_dns}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.quorum_maker_node_dns}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.quorum_maker_node_dns}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.quorum_maker_node_dns}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.quorum_maker_node_dns}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.quorum_maker_node_dns}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.quorum_maker_node_dns}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.quorum_maker_node_dns}"
  }
}

output "quorum_validator_node_dns" {
  value = {
    us-east-1      = "${module.quorum_cluster_us_east_1.quorum_validator_node_dns}"
    us-east-2      = "${module.quorum_cluster_us_east_2.quorum_validator_node_dns}"
    us-west-1      = "${module.quorum_cluster_us_west_1.quorum_validator_node_dns}"
    us-west-2      = "${module.quorum_cluster_us_west_2.quorum_validator_node_dns}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.quorum_validator_node_dns}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.quorum_validator_node_dns}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.quorum_validator_node_dns}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.quorum_validator_node_dns}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.quorum_validator_node_dns}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.quorum_validator_node_dns}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.quorum_validator_node_dns}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.quorum_validator_node_dns}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.quorum_validator_node_dns}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.quorum_validator_node_dns}"
  }
}

output "quorum_observer_node_ips" {
  value = {
    us-east-1      = "${module.quorum_cluster_us_east_1.quorum_observer_node_ips}"
    us-east-2      = "${module.quorum_cluster_us_east_2.quorum_observer_node_ips}"
    us-west-1      = "${module.quorum_cluster_us_west_1.quorum_observer_node_ips}"
    us-west-2      = "${module.quorum_cluster_us_west_2.quorum_observer_node_ips}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.quorum_observer_node_ips}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.quorum_observer_node_ips}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.quorum_observer_node_ips}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.quorum_observer_node_ips}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.quorum_observer_node_ips}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.quorum_observer_node_ips}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.quorum_observer_node_ips}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.quorum_observer_node_ips}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.quorum_observer_node_ips}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.quorum_observer_node_ips}"
  }
}

output "bootnode_ips" {
  value = {
    us-east-1      = "${module.quorum_cluster_us_east_1.bootnode_ips}"
    us-east-2      = "${module.quorum_cluster_us_east_2.bootnode_ips}"
    us-west-1      = "${module.quorum_cluster_us_west_1.bootnode_ips}"
    us-west-2      = "${module.quorum_cluster_us_west_2.bootnode_ips}"
    eu-central-1   = "${module.quorum_cluster_eu_central_1.bootnode_ips}"
    eu-west-1      = "${module.quorum_cluster_eu_west_1.bootnode_ips}"
    eu-west-2      = "${module.quorum_cluster_eu_west_2.bootnode_ips}"
    ap-south-1     = "${module.quorum_cluster_ap_south_1.bootnode_ips}"
    ap-northeast-1 = "${module.quorum_cluster_ap_northeast_1.bootnode_ips}"
    ap-northeast-2 = "${module.quorum_cluster_ap_northeast_2.bootnode_ips}"
    ap-southeast-1 = "${module.quorum_cluster_ap_southeast_1.bootnode_ips}"
    ap-southeast-2 = "${module.quorum_cluster_ap_southeast_2.bootnode_ips}"
    ca-central-1   = "${module.quorum_cluster_ca_central_1.bootnode_ips}"
    sa-east-1      = "${module.quorum_cluster_sa_east_1.bootnode_ips}"
  }
}

output "vault_server_ips" {
  value = "${module.quorum_vault.vault_server_public_ips}"
}
