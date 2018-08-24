variable "network_id" {
  description = <<DESCRIPTION
Ethereum network ID, also used in naming some resources for uniqueness.
Must be unique amongst networks in the same AWS account and launched with this tool.
Ideally is globally unique amongst ethereum and quorum networks.
DESCRIPTION
}

variable "primary_region" {
  description = "The AWS region that single-region resources like the vault and consul clusters are placed in."
}

variable "quorum_vault_vpc_id" {
  description = "The VPC ID of the vault cluster, which will be the requester of all peering connections."
}

variable "quorum_vpc_base_cidr" {
  description = "CIDR Range for all quorum VPCs"
}

variable "bootnode_vpc_base_cidr" {
  description = "CIDR Range for all bootnode VPCs"
}

variable "quorum_vpcs" {
  description = "A mapping from region to the quorum VPC in that region"
  type        = "map"
}

variable "quorum_vpc_peering_counts" {
  description = "A mapping from region to a 1 if there should be a quorum peering connection to that region or 0 otherwise."
  type        = "map"
}

variable "bootnode_vpcs" {
  description = "A mapping from region to the bootnode VPC in that region"
  type        = "map"
}

variable "bootnode_vpc_peering_counts" {
  description = "A mapping from region to a 1 if there should be a bootnode peering connection to that region or 0 otherwise."
  type        = "map"
}
