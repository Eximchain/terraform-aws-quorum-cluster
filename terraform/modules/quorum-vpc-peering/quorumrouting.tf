# ---------------------------------------------------------------------------------------------------------------------
# ROUTES BETWEEN QUORUM VPCS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route" "quorum_us_east_1_to_us_east_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_east_2.id}"
}

resource "aws_route" "quorum_us_east_1_to_us_west_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_west_1.id}"
}

resource "aws_route" "quorum_us_east_1_to_us_west_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_west_2.id}"
}

resource "aws_route" "quorum_us_east_1_to_eu_central_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_central_1.id}"
}

resource "aws_route" "quorum_us_east_1_to_eu_west_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_west_1.id}"
}

resource "aws_route" "quorum_us_east_1_to_eu_west_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_west_2.id}"
}

resource "aws_route" "quorum_us_east_1_to_ap_south_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_south_1.id}"
}

resource "aws_route" "quorum_us_east_1_to_ap_northeast_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_us_east_1_to_ap_northeast_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_us_east_1_to_ap_southeast_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_us_east_1_to_ap_southeast_2" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_us_east_1_to_ca_central_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_us_east_1_to_sa_east_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_us_east_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_east_2.id}"
}

resource "aws_route" "quorum_us_east_2_to_us_west_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_us_west_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_us_west_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_us_west_2.id}"
}

resource "aws_route" "quorum_us_east_2_to_eu_central_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_central_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_eu_west_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_west_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_eu_west_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_west_2.id}"
}

resource "aws_route" "quorum_us_east_2_to_ap_south_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_south_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_ap_northeast_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_ap_northeast_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_us_east_2_to_ap_southeast_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_ap_southeast_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_us_east_2_to_ca_central_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_us_east_2_to_sa_east_1" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_east_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_us_east_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_west_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_us_east_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_us_west_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_us_west_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_us_west_2.id}"
}

resource "aws_route" "quorum_us_west_1_to_eu_central_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_central_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_eu_west_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_west_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_eu_west_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_west_2.id}"
}

resource "aws_route" "quorum_us_west_1_to_ap_south_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_south_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_ap_northeast_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_ap_northeast_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_us_west_1_to_ap_southeast_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_ap_southeast_2" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_us_west_1_to_ca_central_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_us_west_1_to_sa_east_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_us_west_2_to_us_east_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_us_west_2.id}"
}

resource "aws_route" "quorum_us_west_2_to_us_east_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_us_west_2.id}"
}

resource "aws_route" "quorum_us_west_2_to_us_west_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_us_west_2.id}"
}

resource "aws_route" "quorum_us_west_2_to_eu_central_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_central_1.id}"
}

resource "aws_route" "quorum_us_west_2_to_eu_west_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_west_1.id}"
}

resource "aws_route" "quorum_us_west_2_to_eu_west_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_west_2.id}"
}

resource "aws_route" "quorum_us_west_2_to_ap_south_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_south_1.id}"
}

resource "aws_route" "quorum_us_west_2_to_ap_northeast_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_us_west_2_to_ap_northeast_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_us_west_2_to_ap_southeast_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_us_west_2_to_ap_southeast_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_us_west_2_to_ca_central_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_us_west_2_to_sa_east_1" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_us_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_us_east_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_central_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_us_east_2" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_central_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_us_west_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_central_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_us_west_2" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_central_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_eu_west_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_eu_west_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_eu_west_2" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_eu_west_2.id}"
}

resource "aws_route" "quorum_eu_central_1_to_ap_south_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_south_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_ap_northeast_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_ap_northeast_2" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_eu_central_1_to_ap_southeast_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_ap_southeast_2" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_eu_central_1_to_ca_central_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_eu_central_1_to_sa_east_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_us_east_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_west_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_us_east_2" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_west_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_us_west_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_west_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_us_west_2" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_west_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_eu_central_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_eu_west_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_eu_west_2" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_eu_west_2.id}"
}

resource "aws_route" "quorum_eu_west_1_to_ap_south_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_south_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_ap_northeast_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_ap_northeast_2" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_eu_west_1_to_ap_southeast_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_ap_southeast_2" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_eu_west_1_to_ca_central_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_eu_west_1_to_sa_east_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_eu_west_2_to_us_east_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_eu_west_2.id}"
}

resource "aws_route" "quorum_eu_west_2_to_us_east_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_eu_west_2.id}"
}

resource "aws_route" "quorum_eu_west_2_to_us_west_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_eu_west_2.id}"
}

resource "aws_route" "quorum_eu_west_2_to_us_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_eu_west_2.id}"
}

resource "aws_route" "quorum_eu_west_2_to_eu_central_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_eu_west_2.id}"
}

resource "aws_route" "quorum_eu_west_2_to_eu_west_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_eu_west_2.id}"
}

resource "aws_route" "quorum_eu_west_2_to_ap_south_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_south_1.id}"
}

resource "aws_route" "quorum_eu_west_2_to_ap_northeast_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_eu_west_2_to_ap_northeast_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_eu_west_2_to_ap_southeast_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_eu_west_2_to_ap_southeast_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_eu_west_2_to_ca_central_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_eu_west_2_to_sa_east_1" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_eu_west_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_us_east_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_south_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_us_east_2" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_south_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_us_west_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_south_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_us_west_2" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_south_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_eu_central_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_south_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_eu_west_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_south_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_eu_west_2" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_south_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_ap_northeast_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_ap_northeast_2" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_south_1_to_ap_southeast_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_ap_southeast_2" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_south_1_to_ca_central_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ap_south_1_to_sa_east_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_south_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_us_east_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_us_east_2" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_us_west_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_us_west_2" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_eu_central_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_eu_west_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_eu_west_2" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_ap_south_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_northeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_ap_northeast_2" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_ap_southeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_ap_southeast_2" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_ca_central_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ap_northeast_1_to_sa_east_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_us_east_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_us_east_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_us_west_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_us_west_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_eu_central_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_eu_west_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_eu_west_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_ap_south_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_ap_northeast_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_northeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_ap_southeast_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_ap_southeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_ca_central_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ap_northeast_2_to_sa_east_1" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_northeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_us_east_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_us_east_2" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_us_west_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_us_west_2" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_eu_central_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_eu_west_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_eu_west_2" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_ap_south_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_ap_northeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_ap_northeast_2" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ap_southeast_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_ap_southeast_2" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_ca_central_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ap_southeast_1_to_sa_east_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_us_east_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_us_east_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_us_west_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_us_west_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_eu_central_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_eu_west_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_eu_west_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_ap_south_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_ap_northeast_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_ap_northeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_ap_southeast_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_ap_southeast_2.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_ca_central_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ap_southeast_2_to_sa_east_1" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ap_southeast_2.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_us_east_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_us_east_2" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_us_west_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_us_west_2" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_eu_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_eu_west_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_eu_west_2" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_ap_south_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_ap_northeast_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_ap_northeast_2" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_ap_southeast_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_ap_southeast_2" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_2_to_ca_central_1.id}"
}

resource "aws_route" "quorum_ca_central_1_to_sa_east_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) + lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_ca_central_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_sa_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ca_central_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_us_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_us_east_2" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-east-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_east_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_east_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_us_west_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_us_west_2" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "us-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_us_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_us_west_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_eu_central_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_central_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_eu_west_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_eu_west_2" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_eu_west_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_eu_west_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_ap_south_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_south_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_south_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_ap_northeast_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_ap_northeast_2" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_northeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_northeast_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_ap_southeast_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_1_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_ap_southeast_2" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ap_southeast_2.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ap_southeast_2_to_sa_east_1.id}"
}

resource "aws_route" "quorum_sa_east_1_to_ca_central_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0) + lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0) == 2 ? 1 : 0}"

  route_table_id            = "${data.aws_route_table.quorum_sa_east_1.route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.quorum_ca_central_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.quorum_ca_central_1_to_sa_east_1.id}"
}
