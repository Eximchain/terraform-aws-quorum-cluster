variable "owner" {
  description = "The OS user who should be given ownership over the certificate files."
}

variable "organization_name" {
  description = "The name of the organization to associate with the certificates (e.g. Acme Co)."
}

variable "ca_common_name" {
  description = "The common name to use in the subject of the CA certificate (e.g. acme.co cert)."
}

variable "common_name" {
  description = "The common name to use in the subject of the certificate (e.g. acme.co cert)."
}

variable "dns_name" {
  description = "DNS name for which the certificate will be valid (e.g. vault.exim)."
}

variable "validity_period_hours" {
  description = "The number of hours after initial issuing that the certificate will become invalid."
}

variable "network_id" {
  description = <<DESCRIPTION
Ethereum network ID, also used in naming some resources for uniqueness.
Must be unique amongst networks in the same AWS account and launched with this tool.
Ideally is globally unique amongst ethereum and quorum networks.
DESCRIPTION
}
