variable "primary_vpc" {
  description = "The primary VPC to attach the hosted zone to. Should generally be the vault-consul VPC."
}

variable "vault_lb_dns_name" {
  description = "The DNS name of the vault load balancer"
}

variable "vault_lb_zone_id" {
  description = "The hosted zone id of the vault load balancer"
}

variable "quorum_vpcs" {
  description = "A mapping from region to the quorum VPC in that region"
  type        = "map"
}

variable "quorum_vpc_association_counts" {
  description = "A mapping from region to a 1 if there should be a quorum hosted zone association with that region or 0 otherwise."
  type        = "map"
}

variable "bootnode_vpcs" {
  description = "A mapping from region to the bootnode VPC in that region"
  type        = "map"
}

variable "bootnode_vpc_association_counts" {
  description = "A mapping from region to a 1 if there should be a bootnode hosted zone association with that region or 0 otherwise."
  type        = "map"
}

variable "network_id" {
  description = <<DESCRIPTION
Ethereum network ID, also used in naming some resources for uniqueness.
Must be unique amongst networks in the same AWS account and launched with this tool.
Ideally is globally unique amongst ethereum and quorum networks.
DESCRIPTION
}

variable "root_domain" {
  description = "The base domain for the hosted zone"
  default     = "exim"
}

variable "sub_domain_vault" {
  description = "The sub domain for the vault LB"
  default     = "vault"
}
