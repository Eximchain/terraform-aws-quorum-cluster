resource "aws_s3_bucket" "quorum_vault" {
  bucket_prefix = "quorum-vault-network-${var.network_id}-"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE VAULT SERVER CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "vault_cluster" {
  source = "github.com/hashicorp/terraform-aws-vault.git//modules/vault-cluster?ref=v0.0.8"

  cluster_name  = "quorum-vault"
  cluster_size  = "${var.vault_cluster_size}"
  instance_type = "${var.vault_instance_type}"

  ami_id    = "${lookup(var.vault_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_vault_cluster.rendered}"

  s3_bucket_name          = "${aws_s3_bucket.quorum_vault.id}"
  force_destroy_s3_bucket = "${var.force_destroy_s3_buckets}"

  vpc_id     = "${aws_vpc.quorum_cluster.id}"
  subnet_ids = "${aws_subnet.quorum_cluster.*.id}"

  allowed_ssh_cidr_blocks            = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks        = ["0.0.0.0/0"]
#  allowed_inbound_security_group_ids = ["${aws_security_group.default.id}"]
  allowed_inbound_security_group_ids = []
  ssh_key_name                       = "${aws_key_pair.auth.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW VAULT CLUSTER TO USE AWS AUTH
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "allow_aws_auth" {
  name        = "allow_aws_auth_network_${var.network_id}"
  description = "Allow authentication to vault by AWS mechanisms"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole"
    ],
    "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_aws_auth" {
  role       = "${module.vault_cluster.iam_role_id}"
  policy_arn = "${aws_iam_policy.allow_aws_auth.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our Vault servers to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.1.0"

  iam_role_id = "${module.vault_cluster.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH VAULT SERVER WHEN IT'S BOOTING
# This script will configure and start Vault
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data/user-data-vault.sh")}"

  vars {
    aws_region               = "${var.aws_region}"
    s3_bucket_name           = "${aws_s3_bucket.quorum_vault.id}"
    consul_cluster_tag_key   = "${module.consul_cluster.cluster_tag_key}"
    consul_cluster_tag_value = "${module.consul_cluster.cluster_tag_value}"
    network_id               = "${var.network_id}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL SERVER CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "consul_cluster" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.1.0"

  cluster_name  = "quorum-consul"
  cluster_size  = "${var.consul_cluster_size}"
  instance_type = "${var.consul_instance_type}"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "consul-cluster"
  cluster_tag_value = "quorum-consul"

  ami_id    = "${lookup(var.vault_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_consul.rendered}"

  vpc_id     = "${aws_vpc.quorum_cluster.id}"
  subnet_ids = "${aws_subnet.quorum_cluster.*.id}"

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
#  allowed_inbound_security_group_ids = ["${aws_security_group.default.id}"]
  ssh_key_name                = "${aws_key_pair.auth.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER WHEN IT'S BOOTING
# This script will configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_consul" {
  template = "${file("${path.module}/user-data/user-data-consul.sh")}"

  vars {
    consul_cluster_tag_key   = "${module.consul_cluster.cluster_tag_key}"
    consul_cluster_tag_value = "${module.consul_cluster.cluster_tag_value}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# EXPORT CURRENT VAULT SERVER IPS
# These servers may change over time but you can use an arbitrary server for initial setup
# ---------------------------------------------------------------------------------------------------------------------
data "aws_instances" "vault_servers" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["${module.vault_cluster.asg_name}"]
  }
}
