# ---------------------------------------------------------------------------------------------------------------------
# QUORUM MAKER NETWORK ACLS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_network_acl" "quorum_maker" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  vpc_id     = "${aws_vpc.quorum_cluster.id}"
  subnet_ids = ["${aws_subnet.quorum_maker.*.id}"]

  tags {
    Name      = "Quorum Maker ACL Network ${var.network_id}"
    NetworkId = "${var.network_id}"
  }
}

resource "aws_network_acl_rule" "quorum_maker_allow_all_ingress" {
  count = "${aws_network_acl.quorum_maker.count}"

  network_acl_id = "${aws_network_acl.quorum_maker.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "quorum_maker_allow_all_egress" {
  count = "${aws_network_acl.quorum_maker.count}"

  network_acl_id = "${aws_network_acl.quorum_maker.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "quorum_maker_deny_observer_ingress" {
  count = "${aws_network_acl.quorum_maker.count == 1 ? length(compact(var.quorum_observer_cidrs)) : 0}"

  network_acl_id = "${aws_network_acl.quorum_maker.id}"
  rule_number    = "${99 - count.index}"
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "${element(compact(var.quorum_observer_cidrs), count.index)}"
}

resource "aws_network_acl_rule" "quorum_maker_deny_observer_egress" {
  count = "${aws_network_acl.quorum_maker.count == 1 ? length(compact(var.quorum_observer_cidrs)) : 0}"

  network_acl_id = "${aws_network_acl.quorum_maker.id}"
  rule_number    = "${99 - count.index}"
  egress         = true
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "${element(compact(var.quorum_observer_cidrs), count.index)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM VALIDATOR NETWORK ACLS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_network_acl" "quorum_validator" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  vpc_id     = "${aws_vpc.quorum_cluster.id}"
  subnet_ids = ["${aws_subnet.quorum_validator.*.id}"]

  tags {
    Name      = "Quorum Validator ACL Network ${var.network_id}"
    NetworkId = "${var.network_id}"
  }
}

resource "aws_network_acl_rule" "quorum_validator_allow_all_ingress" {
  count = "${aws_network_acl.quorum_validator.count}"

  network_acl_id = "${aws_network_acl.quorum_validator.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "quorum_validator_allow_all_egress" {
  count = "${aws_network_acl.quorum_validator.count}"

  network_acl_id = "${aws_network_acl.quorum_validator.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM OBSERVER NETWORK ACLS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_network_acl" "quorum_observer" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  vpc_id     = "${aws_vpc.quorum_cluster.id}"
  subnet_ids = ["${aws_subnet.quorum_observer.*.id}"]

  tags {
    Name      = "Quorum Observer ACL Network ${var.network_id}"
    NetworkId = "${var.network_id}"
  }
}

resource "aws_network_acl_rule" "quorum_observer_allow_all_ingress" {
  count = "${aws_network_acl.quorum_observer.count}"

  network_acl_id = "${aws_network_acl.quorum_observer.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "quorum_observer_allow_all_egress" {
  count = "${aws_network_acl.quorum_observer.count}"

  network_acl_id = "${aws_network_acl.quorum_observer.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "quorum_observer_deny_maker_ingress" {
  count = "${aws_network_acl.quorum_observer.count == 1 ? length(compact(var.quorum_maker_cidrs)) : 0}"

  network_acl_id = "${aws_network_acl.quorum_observer.id}"
  rule_number    = "${99 - count.index}"
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "${element(compact(var.quorum_maker_cidrs), count.index)}"
}

resource "aws_network_acl_rule" "quorum_observer_deny_maker_egress" {
  count = "${aws_network_acl.quorum_observer.count == 1 ? length(compact(var.quorum_maker_cidrs)) : 0}"

  network_acl_id = "${aws_network_acl.quorum_observer.id}"
  rule_number    = "${99 - count.index}"
  egress         = true
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "${element(compact(var.quorum_maker_cidrs), count.index)}"
}
