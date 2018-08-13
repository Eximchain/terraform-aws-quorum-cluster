data "template_file" "vault_cluster_name" {
  template = "quorum-vault-network-$${network_id}"

  vars {
    network_id = "${var.network_id}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN AUTO SCALING GROUP (ASG) TO RUN VAULT
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "vault_cluster" {
  launch_configuration = "${aws_launch_configuration.vault_cluster.name}"

  vpc_zone_identifier = ["${aws_subnet.vault_consul.*.id}"]

  # Use a fixed-size cluster
  min_size             = "${var.vault_cluster_size}"
  max_size             = "${var.vault_cluster_size}"
  desired_capacity     = "${var.vault_cluster_size}"
  termination_policies = ["Default"]

  target_group_arns         = ["${aws_lb_target_group.quorum_vault.arn}"]

  health_check_type         = "EC2"
  health_check_grace_period = 300
  wait_for_capacity_timeout = "10m"

  tags = [
    {
      key                 = "Name"
      value               = "${data.template_file.vault_cluster_name.rendered}"
      propagate_at_launch = true
    },{
      key                 = "Role"
      value               = "Vault"
      propagate_at_launch = true
    },{
      key                 = "NetworkId"
      value               = "${var.network_id}"
      propagate_at_launch = true
    },{
      key                 = "Region"
      value               = "${var.aws_region}"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE LAUNCH CONFIGURATION TO DEFINE WHAT RUNS ON EACH INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "vault_cluster" {
  name_prefix   = "${data.template_file.vault_cluster_name.rendered}-"
  image_id      = "${var.vault_consul_ami == "" ? data.aws_ami.vault_consul.id : var.vault_consul_ami}"
  instance_type = "${var.vault_instance_type}"
  user_data     = "${data.template_file.user_data_vault_cluster.rendered}"

  iam_instance_profile        = "${aws_iam_instance_profile.vault_cluster.name}"
  key_name                    = "${aws_key_pair.auth.id}"
  security_groups             = ["${aws_security_group.vault_cluster.id}"]
  placement_tenancy           = "${var.use_dedicated_vault_servers ? "dedicated" : "default"}"
  associate_public_ip_address = true

  ebs_optimized = false

  root_block_device {
    volume_type           = "standard"
    volume_size           = 50
    delete_on_termination = true
  }

  # Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one resource, you must
  # also set it in every resource that it depends on, or you'll get an error about cyclic dependencies (especially when
  # removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle {
    create_before_destroy = true
  }

  # user-data needs to download these objects
  depends_on = ["aws_s3_bucket_object.vault_ca_public_key", "aws_s3_bucket_object.vault_public_key", "aws_s3_bucket_object.vault_private_key"]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH VAULT SERVER WHEN IT'S BOOTING
# This script will configure and start Vault
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data/user-data-vault.sh")}"

  vars {
    aws_region                   = "${var.aws_region}"
    s3_bucket_name               = "${aws_s3_bucket.vault_storage.id}"
    consul_cluster_tag_key       = "${module.consul_cluster.cluster_tag_key}"
    consul_cluster_tag_value     = "${module.consul_cluster.cluster_tag_value}"
    network_id                   = "${var.network_id}"
    vault_cert_bucket            = "${aws_s3_bucket.vault_certs.bucket}"
    kms_unseal_key_id            = "${join("", aws_kms_key.vault_unseal.*.key_id)}"
    vault_enterprise_license_key = "${var.vault_enterprise_license_key}"
    threatstack_deploy_key       = "${var.threatstack_deploy_key}"
    maker_node_count_json        = "${data.template_file.maker_node_count_json.rendered}"
    validator_node_count_json    = "${data.template_file.validator_node_count_json.rendered}"
    observer_node_count_json     = "${data.template_file.observer_node_count_json.rendered}"
    bootnode_count_json          = "${data.template_file.bootnode_count_json.rendered}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# EXPORT CURRENT VAULT SERVER IPS
# These servers may change over time but you can use an arbitrary server for initial setup
# ---------------------------------------------------------------------------------------------------------------------
data "aws_instances" "vault_servers" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = ["${aws_autoscaling_group.vault_cluster.name}"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "vault_cluster" {
  name_prefix = "${data.template_file.vault_cluster_name.rendered}-"
  description = "Security group for the ${data.template_file.vault_cluster_name.rendered} launch configuration"
  vpc_id      = "${aws_vpc.vault_consul.id}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

# TODO: Swap to list interpolation for cidr_blocks once Terraform v0.12 is released, consider inputting list directly to module
resource "aws_security_group_rule" "vault_ssh" {
  count = "${length(var.ssh_ips) > 0 ? length(var.ssh_ips) : 1}"

  security_group_id = "${aws_security_group.vault_cluster.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["${length(var.ssh_ips) == 0 ? "0.0.0.0/0" : format("%s/32", element(concat(var.ssh_ips, list("")), count.index))}"]
}

resource "aws_security_group_rule" "vault_allow_api_inbound_from_cidr_blocks" {
  type        = "ingress"
  from_port   = "${var.vault_port}"
  to_port     = "${var.vault_port}"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vault_cluster.id}"
}

resource "aws_security_group_rule" "vault_allow_cluster_inbound_from_self" {
  type      = "ingress"
  from_port = 8201
  to_port   = 8201
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.vault_cluster.id}"
}

resource "aws_security_group_rule" "vault_allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vault_cluster.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM ROLE TO EACH EC2 INSTANCE
# We can use the IAM role to grant the instance IAM permissions so we can use the AWS APIs without having to figure out
# how to get our secret AWS access keys onto the box.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "vault_cluster" {
  name_prefix = "${data.template_file.vault_cluster_name.rendered}-"
  path        = "/"
  role        = "${aws_iam_role.vault_cluster.name}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "vault_cluster" {
  name_prefix        = "${data.template_file.vault_cluster_name.rendered}-"
  assume_role_policy = "${data.aws_iam_policy_document.vault_cluster.json}"

  # aws_iam_instance_profile.instance_profile in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "vault_cluster" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN S3 BUCKET TO USE AS A STORAGE BACKEND
# Also, add an IAM role policy that gives the Vault servers access to this S3 bucket
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "vault_storage" {
  bucket_prefix = "quorum-vault-network-${var.network_id}-"
  force_destroy = "${var.force_destroy_s3_bucket}"

  tags {
    Description = "Used for secret storage with Vault. DO NOT DELETE this Bucket unless you know what you are doing."
  }
}

resource "aws_iam_policy" "vault_s3" {
  name   = "vault_s3_network_${var.network_id}"
  policy = "${data.aws_iam_policy_document.vault_s3.json}"

  description = "Allow vault access to S3 backend"
}

data "aws_iam_policy_document" "vault_s3" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      "${aws_s3_bucket.vault_storage.arn}",
      "${aws_s3_bucket.vault_storage.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "vault_s3" {
  role       = "${aws_iam_role.vault_cluster.id}"
  policy_arn = "${aws_iam_policy.vault_s3.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW VAULT CLUSTER TO USE AWS AUTH
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "allow_aws_auth" {
  name   = "allow_aws_auth_network_${var.network_id}"
  policy = "${data.aws_iam_policy_document.allow_aws_auth.json}"

  description = "Allow authentication to vault by AWS mechanisms"
}

data "aws_iam_policy_document" "allow_aws_auth" {
  statement {
    effect  = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "allow_aws_auth" {
  role       = "${aws_iam_role.vault_cluster.id}"
  policy_arn = "${aws_iam_policy.allow_aws_auth.arn}"
}
