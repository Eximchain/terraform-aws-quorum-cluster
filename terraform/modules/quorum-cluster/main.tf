terraform {
  required_version = ">= 0.9.3"
}

provider "aws" {
  version = "~> 1.5"

  region  = "${var.aws_region}"
}

provider "template" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.0"
}

resource "aws_vpc" "quorum_cluster" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.quorum_cluster.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.quorum_cluster.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "quorum_cluster" {
  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  count                   = "${length(var.quorum_azs)}"
  availability_zone       = "${element(var.quorum_azs, count.index)}"
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
}

resource "aws_key_pair" "auth" {
  key_name   = "quorum-cluster-${var.network_id}"
  public_key = "${file(var.public_key_path)}"
}
