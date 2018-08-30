# ---------------------------------------------------------------------------------------------------------------------
# ROUTES OUTBOUND FROM VAULT TO QUORUM
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route" "vault_to_quorum_us_east_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_us_east_1.id}"
}

resource "aws_route" "vault_to_quorum_us_east_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_us_east_2.id}"
}

resource "aws_route" "vault_to_quorum_us_west_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_us_west_1.id}"
}

resource "aws_route" "vault_to_quorum_us_west_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_us_west_2.id}"
}

resource "aws_route" "vault_to_quorum_eu_central_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_eu_central_1.id}"
}

resource "aws_route" "vault_to_quorum_eu_west_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_eu_west_1.id}"
}

resource "aws_route" "vault_to_quorum_eu_west_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_eu_west_2.id}"
}

resource "aws_route" "vault_to_quorum_ap_south_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_south_1.id}"
}

resource "aws_route" "vault_to_quorum_ap_northeast_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_northeast_1.id}"
}

resource "aws_route" "vault_to_quorum_ap_northeast_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_northeast_2.id}"
}

resource "aws_route" "vault_to_quorum_ap_southeast_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_southeast_1.id}"
}

resource "aws_route" "vault_to_quorum_ap_southeast_2" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_southeast_2.id}"
}

resource "aws_route" "vault_to_quorum_ca_central_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ca_central_1.id}"
}

resource "aws_route" "vault_to_quorum_sa_east_1" {
  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_sa_east_1.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTES OUTBOUND FROM VAULT TO BOOTNODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route" "vault_to_bootnode_us_east_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "us-east-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_us_east_1.id}"
}

resource "aws_route" "vault_to_bootnode_us_east_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "us-east-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_us_east_2.id}"
}

resource "aws_route" "vault_to_bootnode_us_west_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "us-west-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_us_west_1.id}"
}

resource "aws_route" "vault_to_bootnode_us_west_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "us-west-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_us_west_2.id}"
}

resource "aws_route" "vault_to_bootnode_eu_central_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-central-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_eu_central_1.id}"
}

resource "aws_route" "vault_to_bootnode_eu_west_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-west-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_eu_west_1.id}"
}

resource "aws_route" "vault_to_bootnode_eu_west_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-west-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_eu_west_2.id}"
}

resource "aws_route" "vault_to_bootnode_ap_south_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-south-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_south_1.id}"
}

resource "aws_route" "vault_to_bootnode_ap_northeast_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-northeast-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_northeast_1.id}"
}

resource "aws_route" "vault_to_bootnode_ap_northeast_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-northeast-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_northeast_2.id}"
}

resource "aws_route" "vault_to_bootnode_ap_southeast_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-southeast-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_southeast_1.id}"
}

resource "aws_route" "vault_to_bootnode_ap_southeast_2" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-southeast-2", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_southeast_2.id}"
}

resource "aws_route" "vault_to_bootnode_ca_central_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "ca-central-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ca_central_1.id}"
}

resource "aws_route" "vault_to_bootnode_sa_east_1" {
  count = "${lookup(var.bootnode_vpc_peering_counts, "sa-east-1", 0)}"

  route_table_id            = "${data.aws_route_table.vault.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.bootnode_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_sa_east_1.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTES INBOUND FROM QUORUM TO VAULT
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route" "quorum_us_east_1_to_vault" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_us_east_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_vault" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_us_east_2.id}"
}

resource "aws_route" "quorum_us_west_1_to_vault" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_us_west_1.id}"
}

resource "aws_route" "quorum_us_west_2_to_vault" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_us_west_2.id}"
}

resource "aws_route" "quorum_eu_central_1_to_vault" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_eu_central_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_vault" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_eu_west_1.id}"
}

resource "aws_route" "quorum_eu_west_2_to_vault" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_eu_west_2.id}"
}

resource "aws_route" "quorum_ap_south_1_to_vault" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_south_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_vault" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_vault" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_vault" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_vault" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ca_central_1_to_vault" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_ca_central_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_vault" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0)}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_quorum_sa_east_1.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTES INBOUND FROM BOOTNODE TO VAULT
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route" "bootnode_us_east_1_to_vault" {
  provider = "aws.us-east-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "us-east-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_us_east_1.id}"
}

resource "aws_route" "bootnode_us_east_2_to_vault" {
  provider = "aws.us-east-2"

  count = "${lookup(var.bootnode_vpc_peering_counts, "us-east-2", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_us_east_2.id}"
}

resource "aws_route" "bootnode_us_west_1_to_vault" {
  provider = "aws.us-west-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "us-west-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_us_west_1.id}"
}

resource "aws_route" "bootnode_us_west_2_to_vault" {
  provider = "aws.us-west-2"

  count = "${lookup(var.bootnode_vpc_peering_counts, "us-west-2", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_us_west_2.id}"
}

resource "aws_route" "bootnode_eu_central_1_to_vault" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-central-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_eu_central_1.id}"
}

resource "aws_route" "bootnode_eu_west_1_to_vault" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-west-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_eu_west_1.id}"
}

resource "aws_route" "bootnode_eu_west_2_to_vault" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.bootnode_vpc_peering_counts, "eu-west-2", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_eu_west_2.id}"
}

resource "aws_route" "bootnode_ap_south_1_to_vault" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-south-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_south_1.id}"
}

resource "aws_route" "bootnode_ap_northeast_1_to_vault" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-northeast-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_northeast_1.id}"
}

resource "aws_route" "bootnode_ap_northeast_2_to_vault" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-northeast-2", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_northeast_2.id}"
}

resource "aws_route" "bootnode_ap_southeast_1_to_vault" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-southeast-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_southeast_1.id}"
}

resource "aws_route" "bootnode_ap_southeast_2_to_vault" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.bootnode_vpc_peering_counts, "ap-southeast-2", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ap_southeast_2.id}"
}

resource "aws_route" "bootnode_ca_central_1_to_vault" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "ca-central-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_ca_central_1.id}"
}

resource "aws_route" "bootnode_sa_east_1_to_vault" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.bootnode_vpc_peering_counts, "sa-east-1", 0)}"

  route_table_id            = "${data.aws_route_table.bootnode_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.vault.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vault_to_bootnode_sa_east_1.id}"
}
