# ---------------------------------------------------------------------------------------------------------------------
# LOAD BALANCER FOR VAULT
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "quorum_vault" {
  internal = false

  subnets         = ["${aws_subnet.vault_consul.*.id}"]
  security_groups = ["${aws_security_group.vault_load_balancer.id}"]
}

resource "aws_lb_target_group" "quorum_vault" {
  name = "vault-lb-target-net-${var.network_id}"
  port = "${var.vault_port}"
  protocol = "HTTPS"
  vpc_id = "${aws_vpc.vault_consul.id}"
}

resource "aws_lb_listener" "quorum_vault" {
  load_balancer_arn = "${aws_lb.quorum_vault.arn}"
  port              = "${var.vault_port}"
  protocol          = "HTTPS"
  ssl_policy        = "${var.lb_ssl_policy}"
  certificate_arn   = "${aws_iam_server_certificate.vault_certs.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.quorum_vault.arn}"
    type             = "forward"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LOAD BALANCER SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "vault_load_balancer" {
  name_prefix = "${data.template_file.vault_cluster_name.rendered}-lb-"
  description = "Security group for the ${data.template_file.vault_cluster_name.rendered} load balancer"
  vpc_id      = "${aws_vpc.vault_consul.id}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "vault_lb_allow_api_inbound_from_cidr_blocks" {
  type        = "ingress"
  from_port   = "${var.vault_port}"
  to_port     = "${var.vault_port}"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vault_load_balancer.id}"
}

resource "aws_security_group_rule" "vault_lb_allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vault_load_balancer.id}"
}
