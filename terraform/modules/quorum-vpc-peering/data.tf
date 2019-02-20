# ---------------------------------------------------------------------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "${var.primary_region}"

  version = "1.56.0"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  version = "1.56.0"
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"

  version = "1.56.0"
}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"

  version = "1.56.0"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"

  version = "1.56.0"
}

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"

  version = "1.56.0"
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"

  version = "1.56.0"
}

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"

  version = "1.56.0"
}

provider "aws" {
  alias  = "ap-south-1"
  region = "ap-south-1"

  version = "1.56.0"
}

provider "aws" {
  alias  = "ap-northeast-1"
  region = "ap-northeast-1"

  version = "1.56.0"
}

provider "aws" {
  alias  = "ap-northeast-2"
  region = "ap-northeast-2"

  version = "1.56.0"
}

provider "aws" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"

  version = "1.56.0"
}

provider "aws" {
  alias  = "ap-southeast-2"
  region = "ap-southeast-2"

  version = "1.56.0"
}

provider "aws" {
  alias  = "ca-central-1"
  region = "ca-central-1"

  version = "1.56.0"
}

provider "aws" {
  alias  = "sa-east-1"
  region = "sa-east-1"

  version = "1.56.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# LOAD VPCs
# ---------------------------------------------------------------------------------------------------------------------
data "aws_vpc" "vault" {
  id = "${var.quorum_vault_vpc_id}"
}

data "aws_vpc" "quorum_us_east_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "us-east-1")}"
}

data "aws_vpc" "quorum_us_east_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0)}"

  id = "${lookup(var.quorum_vpcs, "us-east-2")}"
}

data "aws_vpc" "quorum_us_west_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "us-west-1")}"
}

data "aws_vpc" "quorum_us_west_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0)}"

  id = "${lookup(var.quorum_vpcs, "us-west-2")}"
}

data "aws_vpc" "quorum_eu_central_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "eu-central-1")}"
}

data "aws_vpc" "quorum_eu_west_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "eu-west-1")}"
}

data "aws_vpc" "quorum_eu_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0)}"

  id = "${lookup(var.quorum_vpcs, "eu-west-2")}"
}

data "aws_vpc" "quorum_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "ap-south-1")}"
}

data "aws_vpc" "quorum_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
}

data "aws_vpc" "quorum_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0)}"

  id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
}

data "aws_vpc" "quorum_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
}

data "aws_vpc" "quorum_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0)}"

  id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
}

data "aws_vpc" "quorum_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "ca-central-1")}"
}

data "aws_vpc" "quorum_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0)}"

  id = "${lookup(var.quorum_vpcs, "sa-east-1")}"
}

# ---------------------------------------------------------------------------------------------------------------------
# LOAD ROUTE TABLE FOR EACH VPC
# ---------------------------------------------------------------------------------------------------------------------
data "aws_route_table" "vault" {
  vpc_id = "${var.quorum_vault_vpc_id}"
}

data "aws_route_table" "quorum_us_east_1" {
  provider = "aws.us-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "us-east-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "us-east-1")}"
}

data "aws_route_table" "quorum_us_east_2" {
  provider = "aws.us-east-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-east-2", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "us-east-2")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "us-east-2")}"
}

data "aws_route_table" "quorum_us_west_1" {
  provider = "aws.us-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "us-west-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "us-west-1")}"  
}

data "aws_route_table" "quorum_us_west_2" {
  provider = "aws.us-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "us-west-2", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "us-west-2")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "us-west-2")}"
}

data "aws_route_table" "quorum_eu_central_1" {
  provider = "aws.eu-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-central-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "eu-central-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "eu-central-1")}"
}

data "aws_route_table" "quorum_eu_west_1" {
  provider = "aws.eu-west-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "eu-west-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "eu-west-1")}"
}

data "aws_route_table" "quorum_eu_west_2" {
  provider = "aws.eu-west-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "eu-west-2", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "eu-west-2")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "eu-west-2")}"
}

data "aws_route_table" "quorum_ap_south_1" {
  provider = "aws.ap-south-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-south-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "ap-south-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-south-1")}"
}

data "aws_route_table" "quorum_ap_northeast_1" {
  provider = "aws.ap-northeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-northeast-1")}"
}

data "aws_route_table" "quorum_ap_northeast_2" {
  provider = "aws.ap-northeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-northeast-2", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-northeast-2")}"
}

data "aws_route_table" "quorum_ap_southeast_1" {
  provider = "aws.ap-southeast-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-southeast-1")}"
}

data "aws_route_table" "quorum_ap_southeast_2" {
  provider = "aws.ap-southeast-2"

  count = "${lookup(var.quorum_vpc_peering_counts, "ap-southeast-2", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ap-southeast-2")}"
}

data "aws_route_table" "quorum_ca_central_1" {
  provider = "aws.ca-central-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "ca-central-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "ca-central-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "ca-central-1")}"
}

data "aws_route_table" "quorum_sa_east_1" {
  provider = "aws.sa-east-1"

  count = "${lookup(var.quorum_vpc_peering_counts, "sa-east-1", 0)}"

  vpc_id = "${lookup(var.quorum_vpcs, "sa-east-1")}"

  route_table_id = "${lookup(var.quorum_vpc_main_route_table, "sa-east-1")}"
}
