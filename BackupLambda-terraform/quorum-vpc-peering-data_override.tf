# This file is to be placed in the quorum-vpc-peering directory
# Override the route table and lookup the main routing table used by the VPC

data "aws_route_table" "quorum_us_east_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "us-east-1")}"
}

data "aws_route_table" "quorum_us_east_2" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "us-east-2")}"
}

data "aws_route_table" "quorum_us_west_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "us-west-1")}"
}

data "aws_route_table" "quorum_us_west_2" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "us-west-2")}"
}

data "aws_route_table" "quorum_eu_central_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "eu-central-1")}"
}

data "aws_route_table" "quorum_eu_west_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "eu-west-1")}"
}

data "aws_route_table" "quorum_eu_west_2" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "eu-west-2")}"
}

data "aws_route_table" "quorum_ap_south_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-south-1")}"
}

data "aws_route_table" "quorum_ap_northeast_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-northeast-1")}"
}

data "aws_route_table" "quorum_ap_northeast_2" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-northeast-2")}"
}

data "aws_route_table" "quorum_ap_southeast_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-southeast-1")}"
}

data "aws_route_table" "quorum_ap_southeast_2" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-southeast-2")}"
}

data "aws_route_table" "quorum_ca_central_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ca-central-1")}"
}

data "aws_route_table" "quorum_sa_east_1" {
    route_table_id = "${lookup(var.quorum_vpc_main_route_table, "sa-east-1")}"
}
