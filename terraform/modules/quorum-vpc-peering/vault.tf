# TODO: Fix excess copy/paste
# Each region is its own resource because the count variable cannot be computed
# If that restriction is relaxed, we should convert to one resource for all regions
# There are several issues regarding this on Hashicorp's GitHub

# ---------------------------------------------------------------------------------------------------------------------
# CONNECTIONS TO QUORUM NODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc_peering_connection" "vault_to_quorum_us_east_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-east-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in us-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "us-east-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_us_east_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-east-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in us-east-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "us-east-2"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_us_west_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-west-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in us-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "us-west-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_us_west_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-west-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in us-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "us-west-2"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_eu_central_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-central-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "eu-cenrtal-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_eu_west_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_eu_west_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_ap_south_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_ap_northeast_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_ap_northeast_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_ap_southeast_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_ap_southeast_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_ca_central_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_quorum_sa_east_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to quorum in sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Vault"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CONNECTIONS TO BOOTNODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc_peering_connection" "vault_to_bootnode_us_east_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "us-east-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "us-east-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in us-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "us-east-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_us_east_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "us-east-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "us-east-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in us-east-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "us-east-2"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_us_west_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "us-west-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "us-west-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in us-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "us-west-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_us_west_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "us-west-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "us-west-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in us-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "us-west-2"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_eu_central_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-central-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "eu-central-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "eu-central-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_eu_west_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-west-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "eu-west-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "eu-west-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_eu_west_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-west-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "eu-west-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "eu-west-2"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_ap_south_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-south-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "ap-south-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-south-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_ap_northeast_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-northeast-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "ap-northeast-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-northeast-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_ap_northeast_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-northeast-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "ap-northeast-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-northeast-2"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_ap_southeast_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-southeast-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "ap-southeast-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-southeast-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_ap_southeast_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-southeast-2", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "ap-southeast-2")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ap-southeast-2"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_ca_central_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ca-central-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "ca-central-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "ca-central-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}

resource "aws_vpc_peering_connection" "vault_to_bootnode_sa_east_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "sa-east-1", 0)}"

  auto_accept = true

  vpc_id      = "${var.quorum_vault_vpc_id}"
  peer_vpc_id = "${lookup(var.bootnode_vpcs, "sa-east-1")}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name       = "Network ${var.network_id} VPC peering to bootnode in sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "${var.primary_region}"
    ToRegion   = "sa-east-1"
    ToType     = "Bootnode"
    FromType   = "Vault"
  }
}
