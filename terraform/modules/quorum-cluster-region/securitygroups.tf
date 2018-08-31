# ---------------------------------------------------------------------------------------------------------------------
# QUORUM MAKER SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "quorum_maker" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  name_prefix = "quorum-maker-net-${var.network_id}-"
  description = "Quorum maker nodes in network ${var.network_id}"
  vpc_id      = "${aws_vpc.quorum_cluster.id}"
}

# TODO: Swap to list interpolation for cidr_blocks once Terraform v0.12 is released
resource "aws_security_group_rule" "quorum_maker_ssh" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0) == 0 ? 0 : length(var.ssh_ips) > 0 ? length(var.ssh_ips) : 1}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["${length(var.ssh_ips) == 0 ? "0.0.0.0/0" : format("%s/32", element(concat(var.ssh_ips, list("")), count.index))}"]
}

resource "aws_security_group_rule" "quorum_maker_constellation" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "ingress"

  from_port = 9000
  to_port   = 9000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_maker_quorum" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_maker_udp" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_maker_rpc" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "ingress"

  from_port = 22000
  to_port   = 22000
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "quorum_maker_supervisor_rpc" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "ingress"

  from_port = 9001
  to_port   = 9001
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "quorum_maker_bootnode" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "ingress"

  from_port = 30301
  to_port   = 30301
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_maker_egress" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM VALIDATOR SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "quorum_validator" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  name_prefix = "quorum-validator-net-${var.network_id}-"
  description = "Quorum validator nodes in network ${var.network_id}"
  vpc_id      = "${aws_vpc.quorum_cluster.id}"
}

# TODO: Swap to list interpolation for cidr_blocks once Terraform v0.12 is released
resource "aws_security_group_rule" "quorum_validator_ssh" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0) == 0 ? 0 : length(var.ssh_ips) > 0 ? length(var.ssh_ips) : 1}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["${length(var.ssh_ips) == 0 ? "0.0.0.0/0" : format("%s/32", element(concat(var.ssh_ips, list("")), count.index))}"]
}

resource "aws_security_group_rule" "quorum_validator_constellation" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "ingress"

  from_port = 9000
  to_port   = 9000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_validator_quorum" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

# TODO: Swap to list interpolation for cidr_blocks once Terraform v0.12 is released
resource "aws_security_group_rule" "quorum_validator_extra_quorum" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0) == 0 ? 0 : length(var.other_validator_connection_ips)}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["${format("%s/32", element(concat(var.other_validator_connection_ips, list("")), count.index))}"]
}

resource "aws_security_group_rule" "quorum_validator_udp" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_validator_rpc" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "ingress"

  from_port = 22000
  to_port   = 22000
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "quorum_validator_supervisor_rpc" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "ingress"

  from_port = 9001
  to_port   = 9001
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "quorum_validator_bootnode" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "ingress"

  from_port = 30301
  to_port   = 30301
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_validator_egress" {
  count = "${signum(lookup(var.validator_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_validator.id}"
  type              = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM OBSERVER SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "quorum_observer" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  name_prefix = "quorum-observer-net-${var.network_id}-"
  description = "Quorum observer nodes in network ${var.network_id}"
  vpc_id      = "${aws_vpc.quorum_cluster.id}"
}

# TODO: Swap to list interpolation for cidr_blocks once Terraform v0.12 is released
resource "aws_security_group_rule" "quorum_observer_ssh" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0) == 0 ? 0 : length(var.ssh_ips) > 0 ? length(var.ssh_ips) : 1}"

  security_group_id = "${aws_security_group.quorum_observer.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["${length(var.ssh_ips) == 0 ? "0.0.0.0/0" : format("%s/32", element(concat(var.ssh_ips, list("")), count.index))}"]
}

resource "aws_security_group_rule" "quorum_observer_constellation" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_observer.id}"
  type              = "ingress"

  from_port = 9000
  to_port   = 9000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_observer_quorum" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_observer.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_observer_udp" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_observer.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_observer_rpc" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_observer.id}"
  type              = "ingress"

  from_port = 22000
  to_port   = 22000
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "quorum_observer_supervisor_rpc" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_observer.id}"
  type              = "ingress"

  from_port = 9001
  to_port   = 9001
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "quorum_observer_bootnode" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_observer.id}"
  type              = "ingress"

  from_port = 30301
  to_port   = 30301
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "quorum_observer_egress" {
  count = "${signum(lookup(var.observer_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_observer.id}"
  type              = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# BOOTNODE SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "bootnode" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  name        = "bootnodes"
  description = "Used for quorum bootnodes"
  vpc_id      = "${aws_vpc.quorum_cluster.id}"
}

# TODO: Swap to list interpolation for cidr_blocks once Terraform v0.12 is released
resource "aws_security_group_rule" "bootnode_ssh" {
  count = "${lookup(var.bootnode_counts, var.aws_region, 0) == 0 ? 0 : length(var.ssh_ips) > 0 ? length(var.ssh_ips) : 1}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["${length(var.ssh_ips) == 0 ? "0.0.0.0/0" : format("%s/32", element(concat(var.ssh_ips, list("")), count.index))}"]
}

resource "aws_security_group_rule" "bootnode_constellation" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 9000
  to_port   = 9000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_quorum" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_quorum_udp" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 21000
  to_port   = 21000
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_rpc" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 22000
  to_port   = 22000
  protocol  = "tcp"

  cidr_blocks = ["127.0.0.1/32"]
}

resource "aws_security_group_rule" "bootnode_bootnode" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "ingress"

  from_port = 30301
  to_port   = 30301
  protocol  = "udp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bootnode_egress" {
  count = "${signum(lookup(var.bootnode_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.bootnode.id}"
  type              = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}
