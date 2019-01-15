# ---------------------------------------------------------------------------------------------------------------------
#  ROUTE53 PRIVATE HOSTED ZONE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "root" {
  name    = "${var.root_domain}"
  comment = "Shared internal DNS for network ${var.network_id}"

  vpc {
    vpc_id = "${var.primary_vpc}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
#  ASSOCIATIONS WITH QUORUM VPCS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone_association" "quorum_us_east_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "us-east-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "us-east-1")}"
  vpc_region = "us-east-1"
}

resource "aws_route53_zone_association" "quorum_us_east_2" {
  count = "${lookup(var.quorum_vpc_association_counts, "us-east-2", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "us-east-2")}"
  vpc_region = "us-east-2"
}

resource "aws_route53_zone_association" "quorum_us_west_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "us-west-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "us-west-1")}"
  vpc_region = "us-west-1"
}

resource "aws_route53_zone_association" "quorum_us_west_2" {
  count = "${lookup(var.quorum_vpc_association_counts, "us-west-2", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "us-west-2")}"
  vpc_region = "us-west-2"
}

resource "aws_route53_zone_association" "quorum_eu_central_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "eu-central-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "eu-central-1")}"
  vpc_region = "eu-central-1"
}

resource "aws_route53_zone_association" "quorum_eu_west_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "eu-west-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "eu-west-1")}"
  vpc_region = "eu-west-1"
}

resource "aws_route53_zone_association" "quorum_eu_west_2" {
  count = "${lookup(var.quorum_vpc_association_counts, "eu-west-2", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "eu-west-2")}"
  vpc_region = "eu-west-2"
}

resource "aws_route53_zone_association" "quorum_ap_south_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "ap-south-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "ap-south-1")}"
  vpc_region = "ap-south-1"
}

resource "aws_route53_zone_association" "quorum_ap_northeast_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "ap-northeast-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "ap-northeast-1")}"
  vpc_region = "ap-northeast-1"
}

resource "aws_route53_zone_association" "quorum_ap_northeast_2" {
  count = "${lookup(var.quorum_vpc_association_counts, "ap-northeast-2", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "ap-northeast-2")}"
  vpc_region = "ap-northeast-2"
}

resource "aws_route53_zone_association" "quorum_ap_southeast_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "ap-southeast-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "ap-southeast-1")}"
  vpc_region = "ap-southeast-1"
}

resource "aws_route53_zone_association" "quorum_ap_southeast_2" {
  count = "${lookup(var.quorum_vpc_association_counts, "ap-southeast-2", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "ap-southeast-2")}"
  vpc_region = "ap-southeast-2"
}

resource "aws_route53_zone_association" "quorum_ca_central_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "ca-central-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "ca-central-1")}"
  vpc_region = "ca-central-1"
}

resource "aws_route53_zone_association" "quorum_sa_east_1" {
  count = "${lookup(var.quorum_vpc_association_counts, "sa-east-1", 0)}"

  zone_id    = "${aws_route53_zone.root.zone_id}"
  vpc_id     = "${lookup(var.quorum_vpcs, "sa-east-1")}"
  vpc_region = "sa-east-1"
}

# ---------------------------------------------------------------------------------------------------------------------
#  DNS RECORDS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "vault" {
  zone_id = "${aws_route53_zone.root.zone_id}"
  name    = "${format("%s.%s", var.sub_domain_vault, var.root_domain)}"
  type    = "A"

  alias {
    name                   = "${var.vault_lb_dns_name}"
    zone_id                = "${var.vault_lb_zone_id}"
    evaluate_target_health = false
  }
}
