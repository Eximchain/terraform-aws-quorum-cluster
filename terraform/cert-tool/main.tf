provider "aws" {
  version = "~> 2.4.0"
  region  = "us-east-1"
}

provider "null" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.2"
}

module "cert_tool" {
  source = "../modules/cert-tool"

  use_kms_encryption = true

  network_id              = "${var.network_id}"
  ca_public_key_file_path = "${path.module}/../modules/quorum-vault/certs/ca.crt.pem"
  public_key_file_path    = "${path.module}/../modules/quorum-vault/certs/vault.crt.pem"
  private_key_file_path   = "${path.module}/../modules/quorum-vault/certs/vault.key.pem"
  owner                   = "${var.owner}"
  organization_name       = "${var.organization_name}"
  ca_common_name          = "${var.ca_common_name}"
  common_name             = "${var.common_name}"
  dns_names               = ["${var.dns_name}"]
  ip_addresses            = ["127.0.0.1"]
  validity_period_hours   = "${var.validity_period_hours}"
}
