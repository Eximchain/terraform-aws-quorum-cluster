# ---------------------------------------------------------------------------------------------------------------------
# LOAD BALANCER FOR VAULT
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "quorum_vault" {
  internal = false

  subnets         = ["${aws_subnet.vault_consul.*.id}"]
  security_groups = ["${aws_security_group.vault_cluster.id}"]
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
