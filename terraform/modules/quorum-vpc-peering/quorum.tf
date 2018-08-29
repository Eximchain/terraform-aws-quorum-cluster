# TODO: Fix excess copy/paste
# Each region is its own resource because the count variable cannot be computed
# If that restriction is relaxed, we should convert to one resource for all regions
# There are several issues regarding this on Hashicorp's GitHub

# ---------------------------------------------------------------------------------------------------------------------
# CONNECTIONS BETWEEN QUORUM NODES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_us_east_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_region = "us-east-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum us-east-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "us-east-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_us_east_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_east_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum us-east-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "us-east-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_us_west_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_region = "us-west-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum us-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "us-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_us_west_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_west_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum us-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "us-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_us_west_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_region = "us-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum us-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "us-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_us_west_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum us-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "us-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_eu_central_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_region = "eu-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "eu-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_eu_central_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "eu-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_eu_west_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_region = "eu-west-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_eu_west_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_west_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_eu_west_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_region = "eu-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_eu_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_ap_south_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_region = "ap-south-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_south_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_ap_northeast_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_region = "ap-northeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_northeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_ap_northeast_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_ap_southeast_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_ap_southeast_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_ca_central_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_1_to_sa_east_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_1_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_us_west_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_region = "us-west-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum us-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "us-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_us_west_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_us_west_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum us-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "us-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_us_west_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_region = "us-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum us-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "us-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_us_west_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_us_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum us-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "us-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_eu_central_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_region = "eu-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "eu-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_eu_central_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "eu-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_eu_west_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_region = "eu-west-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_eu_west_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_west_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_eu_west_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_region = "eu-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_eu_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_ap_south_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_region = "ap-south-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_south_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_ap_northeast_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_region = "ap-northeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_northeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_ap_northeast_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_ap_southeast_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_ap_southeast_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_ca_central_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_east_2_to_sa_east_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-east-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-east-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_east_2_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-east-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-east-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_us_west_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_region = "us-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum us-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "us-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_us_west_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_us_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum us-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "us-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_eu_central_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_region = "eu-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "eu-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_eu_central_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "eu-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_eu_west_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_region = "eu-west-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_eu_west_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_west_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_eu_west_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_region = "eu-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_eu_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_ap_south_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_region = "ap-south-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_south_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_ap_northeast_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_region = "ap-northeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_northeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_ap_northeast_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_ap_southeast_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_ap_southeast_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_ca_central_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_1_to_sa_east_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_1_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_eu_central_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_region = "eu-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "eu-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_eu_central_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum eu-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "eu-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_eu_west_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_region = "eu-west-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_eu_west_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_west_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_eu_west_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_region = "eu-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_eu_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_ap_south_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_region = "ap-south-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_south_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_ap_northeast_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_region = "ap-northeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_northeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_ap_northeast_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_ap_southeast_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_ap_southeast_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_ca_central_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_us_west_2_to_sa_east_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "us-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum us-west-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_us_west_2_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum us-west-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "us-west-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_eu_west_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_region = "eu-west-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_eu_west_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_eu_west_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum eu-west-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "eu-west-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_eu_west_2" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_region = "eu-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_eu_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_eu_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_ap_south_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_region = "ap-south-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_south_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_ap_northeast_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_region = "ap-northeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_northeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_ap_northeast_2" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_ap_southeast_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_ap_southeast_2" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_ca_central_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_central_1_to_sa_east_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-central-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_central_1_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-central-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-central-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_1_to_eu_west_2" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_region = "eu-west-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-1 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_1_to_eu_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_eu_west_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-1 to quorum eu-west-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "eu-west-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_1_to_ap_south_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_region = "ap-south-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-1 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_1_to_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_south_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-1 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_1_to_ap_northeast_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_region = "ap-northeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_1_to_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_northeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_1_to_ap_northeast_2" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_1_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_1_to_ap_southeast_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_1_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_1_to_ap_southeast_2" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_1_to_ca_central_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_1_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_1_to_sa_east_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_1_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_2_to_ap_south_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_region = "ap-south-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-2 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_2_to_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_south_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-2 to quorum ap-south-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-south-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_2_to_ap_northeast_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_region = "ap-northeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-2 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_2_to_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_northeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-2 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_2_to_ap_northeast_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-2 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_2_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-2 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_2_to_ap_southeast_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-2 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_2_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-2 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_2_to_ap_southeast_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-2 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_2_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-2 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_2_to_ca_central_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_2_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_eu_west_2_to_sa_east_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum eu-west-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_eu_west_2_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum eu-west-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "eu-west-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_south_1_to_ap_northeast_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_region = "ap-northeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-south-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_south_1_to_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_northeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-south-1 to quorum ap-northeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ap-northeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_south_1_to_ap_northeast_2" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-south-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_south_1_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-south-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_south_1_to_ap_southeast_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-south-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_south_1_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-south-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_south_1_to_ap_southeast_2" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-south-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_south_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-south-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_south_1_to_ca_central_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-south-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_south_1_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-south-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_south_1_to_sa_east_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-south-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_south_1_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-south-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-south-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_1_to_ap_northeast_2" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_region = "ap-northeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_1_to_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_northeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-1 to quorum ap-northeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "ap-northeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_1_to_ap_southeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_1_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-1 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_1_to_ap_southeast_2" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_1_to_ca_central_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_1_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_1_to_sa_east_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_1_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_2_to_ap_southeast_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_region = "ap-southeast-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-2 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-2"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_2_to_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ap_southeast_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-2 to quorum ap-southeast-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-2"
    ToRegion   = "ap-southeast-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_2_to_ap_southeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-2 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-2"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_2_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-2 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-2"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_2_to_ca_central_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_2_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_northeast_2_to_sa_east_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-northeast-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_northeast_2_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-northeast-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-northeast-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_southeast_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_region = "ap-southeast-2"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-southeast-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_southeast_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_ap_southeast_2.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-southeast-1 to quorum ap-southeast-2"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-1"
    ToRegion   = "ap-southeast-2"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_southeast_1_to_ca_central_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-southeast-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_southeast_1_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-southeast-1 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-1"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_southeast_1_to_sa_east_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-southeast-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_southeast_1_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-southeast-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_southeast_2_to_ca_central_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_region = "ca-central-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-southeast-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_southeast_2_to_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_2_to_ca_central_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-southeast-2 to quorum ca-central-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-2"
    ToRegion   = "ca-central-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ap_southeast_2_to_sa_east_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ap-southeast-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ap_southeast_2_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_2_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ap-southeast-2 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ap-southeast-2"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection" "quorum_ca_central_1_to_sa_east_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_id      = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  peer_vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  peer_region = "sa-east-1"

  tags {
    Name       = "Network ${var.network_id} VPC peering from quorum ca-central-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ca-central-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}

resource "aws_vpc_peering_connection_accepter" "quorum_ca_central_1_to_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ca_central_1_to_sa_east_1.id}"
  auto_accept               = true

  tags {
    Name       = "Network ${var.network_id} VPC peering acceptor from quorum ca-central-1 to quorum sa-east-1"
    NetworkId  = "${var.network_id}"
    FromRegion = "ca-central-1"
    ToRegion   = "sa-east-1"
    ToType     = "Quorum"
    FromType   = "Quorum"
  }
}
