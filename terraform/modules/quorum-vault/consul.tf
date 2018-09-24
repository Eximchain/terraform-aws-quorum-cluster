data "template_file" "consul_cluster_name" {
  template = "quorum-consul-network-$${network_id}"

  vars {
    network_id = "${var.network_id}"
  }
}

data "template_file" "consul_cluster_tag_key" {
  template = "consul-cluster"
}

data "template_file" "consul_cluster_tag_value" {
  template = "quorum_consul"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN AUTO SCALING GROUP (ASG) TO RUN CONSUL
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "consul_cluster" {
  launch_configuration = "${aws_launch_configuration.consul_cluster.name}"

  vpc_zone_identifier = ["${aws_subnet.vault_consul.*.id}"]

  # Run a fixed number of instances in the ASG
  min_size             = "${var.consul_cluster_size}"
  max_size             = "${var.consul_cluster_size}"
  desired_capacity     = "${var.consul_cluster_size}"
  termination_policies = ["Default"]

  health_check_type         = "EC2"
  health_check_grace_period = 300
  wait_for_capacity_timeout = "10m"

  tags = [
    {
      key                 = "Name"
      value               = "${data.template_file.consul_cluster_name.rendered}"
      propagate_at_launch = true
    },{
      key                 = "${data.template_file.consul_cluster_tag_key.rendered}"
      value               = "${data.template_file.consul_cluster_tag_value.rendered}"
      propagate_at_launch = true
    },{
      key                 = "Role"
      value               = "Consul"
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

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE LAUNCH CONFIGURATION TO DEFINE WHAT RUNS ON EACH INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "consul_cluster" {
  name_prefix   = "${data.template_file.consul_cluster_name.rendered}-"
  image_id      = "${var.vault_consul_ami == "" ? data.aws_ami.vault_consul.id : var.vault_consul_ami}"
  instance_type = "${var.consul_instance_type}"
  user_data     = "${data.template_file.user_data_consul.rendered}"

  iam_instance_profile        = "${aws_iam_instance_profile.consul_cluster.name}"
  key_name                    = "${aws_key_pair.auth.id}"
  security_groups             = ["${aws_security_group.consul_cluster.id}"]
  placement_tenancy           = "${var.use_dedicated_consul_servers ? "dedicated" : "default"}"
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
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER WHEN IT'S BOOTING
# This script will configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" "user_data_consul" {
  template = "${file("${path.module}/user-data/user-data-consul.sh")}"

  vars {
    consul_cluster_tag_key   = "${data.template_file.consul_cluster_tag_key.rendered}"
    consul_cluster_tag_value = "${data.template_file.consul_cluster_tag_value.rendered}"
    threatstack_deploy_key   = "${var.threatstack_deploy_key}"
    foxpass_base_dn          = "${var.foxpass_base_dn}"
    foxpass_bind_user        = "${var.foxpass_bind_user}"
    foxpass_bind_pw          = "${var.foxpass_bind_pw}"
    foxpass_api_key          = "${var.foxpass_api_key}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "consul_cluster" {
  name_prefix = "${data.template_file.consul_cluster_name.rendered}-"
  description = "Security group for the ${data.template_file.consul_cluster_name.rendered} launch configuration"
  vpc_id      = "${aws_vpc.vault_consul.id}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

# TODO: Swap to list interpolation for cidr_blocks once Terraform v0.12 is released, consider inputting list directly to module
resource "aws_security_group_rule" "consul_ssh" {
  count = "${length(var.ssh_ips) > 0 ? length(var.ssh_ips) : 1}"

  security_group_id = "${aws_security_group.consul_cluster.id}"
  type              = "ingress"

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["${length(var.ssh_ips) == 0 ? "0.0.0.0/0" : format("%s/32", element(concat(var.ssh_ips, list("")), count.index))}"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.consul_cluster.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE CONSUL-SPECIFIC INBOUND/OUTBOUND RULES COME FROM THE CONSUL-SECURITY-GROUP-RULES MODULE
# ---------------------------------------------------------------------------------------------------------------------
module "security_group_rules" {
  source = "../consul-security-group-rules"

  security_group_id                      = "${aws_security_group.consul_cluster.id}"
  allowed_inbound_cidr_blocks            = []
  allowed_inbound_security_group_ids     = ["${aws_security_group.vault_cluster.id}"]
  num_allowed_inbound_security_group_ids = 1
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM ROLE TO EACH EC2 INSTANCE
# We can use the IAM role to grant the instance IAM permissions so we can use the AWS CLI without having to figure out
# how to get our secret AWS access keys onto the box.
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_instance_profile" "consul_cluster" {
  name_prefix = "${data.template_file.consul_cluster_name.rendered}-"
  path        = "/"
  role        = "${aws_iam_role.consul_cluster.name}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "consul_cluster" {
  name_prefix        = "${data.template_file.consul_cluster_name.rendered}-"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"

  # aws_iam_instance_profile.instance_profile in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE IAM POLICIES COME FROM THE CONSUL-IAM-POLICIES MODULE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "consul_auto_discover_cluster" {
  role       = "${aws_iam_role.consul_cluster.id}"
  policy_arn = "${aws_iam_policy.auto_discover_cluster.arn}"
}
