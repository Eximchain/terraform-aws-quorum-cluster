output "vault_lb_fqdn" {
  value = "${aws_route53_record.vault.fqdn}"
}
