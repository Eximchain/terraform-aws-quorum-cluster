# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE NETWORKING
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "quorum_cluster" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  cidr_block           = "${var.quorum_vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name      = "quorum-network-${var.network_id}-nodes"
    VpcType   = "QuorumNodes"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

resource "aws_default_security_group" "quorum_cluster" {
  count = "${aws_vpc.quorum_cluster.count}"

  vpc_id = "${aws_vpc.quorum_cluster.id}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "quorum_cluster" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  vpc_id = "${aws_vpc.quorum_cluster.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "quorum_cluster" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0))}"

  route_table_id         = "${aws_vpc.quorum_cluster.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.quorum_cluster.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# SUBNETS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0) > 0 ? lookup(var.az_override, var.aws_region, "") == "" ? length(data.aws_availability_zones.available.names) : length(split(",", lookup(var.az_override, var.aws_region, ""))) : 0}"

  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  availability_zone       = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(split(",", lookup(var.az_override, var.aws_region, "")), count.index)}"
  cidr_block              = "${cidrsubnet(data.template_file.quorum_maker_cidr_block.rendered, 3, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name      = "quorum-network-${var.network_id}-makers-${count.index}"
    NodeType  = "Maker"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

resource "aws_subnet" "quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0) > 0 ? lookup(var.az_override, var.aws_region, "") == "" ? length(data.aws_availability_zones.available.names) : length(split(",", lookup(var.az_override, var.aws_region, ""))) : 0}"

  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  availability_zone       = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(split(",", lookup(var.az_override, var.aws_region, "")), count.index)}"
  cidr_block              = "${cidrsubnet(data.template_file.quorum_validator_cidr_block.rendered, 3, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name      = "quorum-network-${var.network_id}-validators-${count.index}"
    NodeType  = "Validator"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

resource "aws_subnet" "quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0) > 0 ? lookup(var.az_override, var.aws_region, "") == "" ? length(data.aws_availability_zones.available.names) : length(split(",", lookup(var.az_override, var.aws_region, ""))) : 0}"

  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  availability_zone       = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(split(",", lookup(var.az_override, var.aws_region, "")), count.index)}"
  cidr_block              = "${cidrsubnet(data.template_file.quorum_observer_cidr_block.rendered, 3, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name      = "quorum-network-${var.network_id}-observers-${count.index}"
    NodeType  = "Observer"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

resource "aws_subnet" "public" {
  count = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)) : 0}"

  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  availability_zone       = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(split(",", lookup(var.az_override, var.aws_region, "")), count.index)}"
  cidr_block              = "${cidrsubnet(data.template_file.quorum_backup_lambda_public_cidr_block.rendered, 3, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name       = "quorum-network-${var.network_id}-Public-Subnet"
    SubnetType = "Public"
    NetworkId  = "${var.network_id}"
    Region     = "${var.aws_region}"
  }
}

resource "aws_subnet" "private" {
  count = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)) : 0}"

  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  availability_zone       = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(split(",", lookup(var.az_override, var.aws_region, "")), count.index)}"
  cidr_block              = "${cidrsubnet(data.template_file.quorum_backup_lambda_private_cidr_block.rendered, 3, count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name       = "quorum-network-${var.network_id}-Private-Subnet"
    SubnetType = "Private"
    NetworkId  = "${var.network_id}"
    Region     = "${var.aws_region}"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# ROUTING TABLES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  count = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)) : 0}"

  vpc_id = "${aws_vpc.quorum_cluster.id}"

  tags {
     Name = "BackupLambdaSSH-${var.network_id}-${var.aws_region}-RouteTable-Public"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = "${aws_internet_gateway.quorum_cluster.id}"
  }
}

resource "aws_route_table" "private" {
  count = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)) : 0}"

  vpc_id = "${aws_vpc.quorum_cluster.id}"

  tags {
     Name = "BackupLambdaSSH-${var.network_id}-${var.aws_region}-RouteTable-Private"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.backup_lambda.id}"
  }
}

resource "aws_route_table_association" "public" {
  count = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)) : 0}"

  subnet_id      = "${aws_subnet.public.0.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0)) : 0}"

  subnet_id      = "${aws_subnet.private.0.id}"
  route_table_id = "${aws_route_table.private.id}"
}
# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE ASGs
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "quorum_maker" {
  count = "${aws_launch_configuration.quorum_maker.count}"

  name = "${substr(element(aws_launch_configuration.quorum_maker.*.name_prefix, count.index), 0, length(element(aws_launch_configuration.quorum_maker.*.name_prefix, count.index)) - 1)}"

  launch_configuration = "${element(aws_launch_configuration.quorum_maker.*.name, count.index)}"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = ["${element(aws_subnet.quorum_maker.*.id, count.index)}"]

  tags = [
    {
      key                 = "Name"
      value               = "${substr(element(aws_launch_configuration.quorum_maker.*.name_prefix, count.index), 0, length(element(aws_launch_configuration.quorum_maker.*.name_prefix, count.index)) - 1)}"
      propagate_at_launch = true
    },{
      key                 = "Role"
      value               = "Maker"
      propagate_at_launch = true
    },{
      key                 = "RoleIndex"
      value               = "${count.index}"
      propagate_at_launch = true
    },{
      key                 = "NetworkId"
      value               = "${var.network_id}"
      propagate_at_launch = true
    },{
      key                 = "Region"
      value               = "${var.aws_region}"
      propagate_at_launch = true
    },{
      key                 = "FinalRoleNode"
      value               = "${count.index == aws_launch_configuration.quorum_maker.count - 1 ? "Yes" : "No"}"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "quorum_validator" {
  count = "${aws_launch_configuration.quorum_validator.count}"

  name = "${substr(element(aws_launch_configuration.quorum_validator.*.name_prefix, count.index), 0, length(element(aws_launch_configuration.quorum_validator.*.name_prefix, count.index)) - 1)}"

  launch_configuration = "${element(aws_launch_configuration.quorum_validator.*.name, count.index)}"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = ["${element(aws_subnet.quorum_validator.*.id, count.index)}"]

  tags = [
    {
      key                 = "Name"
      value               = "${substr(element(aws_launch_configuration.quorum_validator.*.name_prefix, count.index), 0, length(element(aws_launch_configuration.quorum_validator.*.name_prefix, count.index)) - 1)}"
      propagate_at_launch = true
    },{
      key                 = "Role"
      value               = "Validator"
      propagate_at_launch = true
    },{
      key                 = "RoleIndex"
      value               = "${count.index}"
      propagate_at_launch = true
    },{
      key                 = "NetworkId"
      value               = "${var.network_id}"
      propagate_at_launch = true
    },{
      key                 = "Region"
      value               = "${var.aws_region}"
      propagate_at_launch = true
    },{
      key                 = "FinalRoleNode"
      value               = "${count.index == aws_launch_configuration.quorum_validator.count - 1 ? "Yes" : "No"}"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "quorum_observer" {
  count = "${aws_launch_configuration.quorum_observer.count}"

  name = "${substr(element(aws_launch_configuration.quorum_observer.*.name_prefix, count.index), 0, length(element(aws_launch_configuration.quorum_observer.*.name_prefix, count.index)) - 1)}"

  launch_configuration = "${element(aws_launch_configuration.quorum_observer.*.name, count.index)}"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = ["${element(aws_subnet.quorum_observer.*.id, count.index)}"]

  tags = [
    {
      key                 = "Name"
      value               = "${substr(element(aws_launch_configuration.quorum_observer.*.name_prefix, count.index), 0, length(element(aws_launch_configuration.quorum_observer.*.name_prefix, count.index)) - 1)}"
      propagate_at_launch = true
    },{
      key                 = "Role"
      value               = "Observer"
      propagate_at_launch = true
    },{
      key                 = "RoleIndex"
      value               = "${count.index}"
      propagate_at_launch = true
    },{
      key                 = "NetworkId"
      value               = "${var.network_id}"
      propagate_at_launch = true
    },{
      key                 = "Region"
      value               = "${var.aws_region}"
      propagate_at_launch = true
    },{
      key                 = "FinalRoleNode"
      value               = "${count.index == aws_launch_configuration.quorum_observer.count - 1 ? "Yes" : "No"}"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# USER DATA SCRIPTS
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" "user_data_quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    index              = "${count.index}"
    overall_index_base = 0

    role = "maker"

    aws_region     = "${var.aws_region}"
    primary_region = "${var.primary_region}"

    vote_threshold   = "${var.vote_threshold}"
    min_block_time   = "${var.min_block_time}"
    max_block_time   = "${var.max_block_time}"
    max_peers        = "${var.max_peers}"
    gas_limit        = "${var.gas_limit}"
    network_id       = "${var.network_id}"

    # Must include these vars on non-observers so user-data-quorum.sh doesn't fail
    use_elastic_observer_ips = "0"
    public_ip                = "nil"
    eip_id                   = "nil"

    generate_metrics   = "${var.generate_metrics}"
    data_backup_bucket = "${aws_s3_bucket.quorum_backup.id}"

    efs_fs_id  = "${var.use_efs ? element(coalescelist(aws_efs_file_system.chain_data.*.id, list("")), 0) : ""}"
    efs_mt_dns = "${var.use_efs ? element(coalescelist(aws_efs_mount_target.chain_data.*.dns_name, list("")), count.index) : ""}"

    chain_data_dir = "${var.use_efs ? "/opt/quorum/mnt/efs/makers/${count.index}/ethereum/" : "/home/ubuntu/.ethereum/"}"

    geth_verbosity = "${var.geth_verbosity}"

    vault_dns  = "${var.vault_dns}"
    vault_port = "${var.vault_port}"

    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_tag_value}"

    vault_cert_bucket       = "${var.vault_cert_bucket_name}"
    constellation_s3_bucket = "${aws_s3_bucket.quorum_constellation.id}"
    node_count_bucket       = "${var.node_count_bucket_name}"

    threatstack_deploy_key = "${var.threatstack_deploy_key}"

    foxpass_base_dn   = "${var.foxpass_base_dn}"
    foxpass_bind_user = "${var.foxpass_bind_user}"
    foxpass_bind_pw   = "${var.foxpass_bind_pw}"
    foxpass_api_key   = "${var.foxpass_api_key}"
  }
}

data "template_file" "user_data_quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    index              = "${count.index}"

    role = "validator"

    aws_region     = "${var.aws_region}"
    primary_region = "${var.primary_region}"

    vote_threshold   = "${var.vote_threshold}"
    min_block_time   = "${var.min_block_time}"
    max_block_time   = "${var.max_block_time}"
    max_peers        = "${var.max_peers}"
    gas_limit        = "${var.gas_limit}"
    network_id       = "${var.network_id}"

    # Must include these vars on non-observers so user-data-quorum.sh doesn't fail
    use_elastic_observer_ips = "0"
    public_ip                = "nil"
    eip_id                   = "nil"

    generate_metrics = "${var.generate_metrics}"
    data_backup_bucket = "${aws_s3_bucket.quorum_backup.id}"

    efs_fs_id  = "${var.use_efs ? element(coalescelist(aws_efs_file_system.chain_data.*.id, list("")), 0) : ""}"
    efs_mt_dns = "${var.use_efs ? element(coalescelist(aws_efs_mount_target.chain_data.*.dns_name, list("")), count.index) : ""}"

    chain_data_dir = "${var.use_efs ? "/opt/quorum/mnt/efs/validators/${count.index}/ethereum/" : "/home/ubuntu/.ethereum/"}"

    geth_verbosity = "${var.geth_verbosity}"

    vault_dns  = "${var.vault_dns}"
    vault_port = "${var.vault_port}"

    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_tag_value}"

    vault_cert_bucket       = "${var.vault_cert_bucket_name}"
    constellation_s3_bucket = "${aws_s3_bucket.quorum_constellation.id}"
    node_count_bucket       = "${var.node_count_bucket_name}"

    threatstack_deploy_key = "${var.threatstack_deploy_key}"

    foxpass_base_dn   = "${var.foxpass_base_dn}"
    foxpass_bind_user = "${var.foxpass_bind_user}"
    foxpass_bind_pw   = "${var.foxpass_bind_pw}"
    foxpass_api_key   = "${var.foxpass_api_key}"
  }
}

data "template_file" "user_data_quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    index              = "${count.index}"

    role = "observer"

    aws_region     = "${var.aws_region}"
    primary_region = "${var.primary_region}"

    vote_threshold   = "${var.vote_threshold}"
    min_block_time   = "${var.min_block_time}"
    max_block_time   = "${var.max_block_time}"
    max_peers        = "${var.max_peers}"
    gas_limit        = "${var.gas_limit}"
    network_id       = "${var.network_id}"

    use_elastic_observer_ips = "${var.use_elastic_observer_ips}"

    # concat() is called to ensure there is always at least one element in the list,
    # as element() cannot be called on empty list.  Solution is hacky, but lazy
    # ternary evaluation will drop in Terraform 0.12: https://www.hashicorp.com/blog/terraform-0-1-2-preview
    # If you're reading this and it has already released, try dropping the concat hack.
    public_ip = "${var.use_elastic_observer_ips ? element(concat(aws_eip.quorum_observer.*.public_ip, list("")), count.index) : "nil"}"
    eip_id    = "${var.use_elastic_observer_ips ? element(concat(aws_eip.quorum_observer.*.id, list("")), count.index) : "nil"}"

    generate_metrics = "${var.generate_metrics}"
    data_backup_bucket = "${aws_s3_bucket.quorum_backup.id}"

    efs_fs_id  = "${var.use_efs ? element(coalescelist(aws_efs_file_system.chain_data.*.id, list("")), 0) : ""}"
    efs_mt_dns = "${var.use_efs ? element(coalescelist(aws_efs_mount_target.chain_data.*.dns_name, list("")), count.index) : ""}"

    chain_data_dir = "${var.use_efs ? "/opt/quorum/mnt/efs/observers/${count.index}/ethereum/" : "/home/ubuntu/.ethereum/"}"

    geth_verbosity = "${var.geth_verbosity}"

    vault_dns  = "${var.vault_dns}"
    vault_port = "${var.vault_port}"

    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_tag_value}"

    vault_cert_bucket       = "${var.vault_cert_bucket_name}"
    constellation_s3_bucket = "${aws_s3_bucket.quorum_constellation.id}"
    node_count_bucket       = "${var.node_count_bucket_name}"

    threatstack_deploy_key = "${var.threatstack_deploy_key}"

    foxpass_base_dn   = "${var.foxpass_base_dn}"
    foxpass_bind_user = "${var.foxpass_bind_user}"
    foxpass_bind_pw   = "${var.foxpass_bind_pw}"
    foxpass_api_key   = "${var.foxpass_api_key}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LAUNCH CONFIGURATIONS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "quorum_maker" {
  count = "${data.template_file.user_data_quorum_maker.count}"

  name_prefix = "quorum-network-${var.network_id}-maker-${count.index}-"

  image_id      = "${var.quorum_ami == "" ? data.aws_ami.quorum.id : var.quorum_ami}"
  instance_type = "${var.quorum_maker_instance_type}"
  user_data     = "${element(data.template_file.user_data_quorum_maker.*.rendered, count.index)}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${element(aws_iam_instance_profile.quorum_maker.*.name, count.index)}"
  security_groups      = ["${aws_security_group.quorum_maker.id}"]

  placement_tenancy = "${var.use_dedicated_makers ? "dedicated" : "default"}"

  root_block_device {
    volume_size = "${var.node_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "quorum_validator" {
  count = "${data.template_file.user_data_quorum_validator.count}"

  name_prefix = "quorum-network-${var.network_id}-validator-${count.index}-"

  image_id      = "${var.quorum_ami == "" ? data.aws_ami.quorum.id : var.quorum_ami}"
  instance_type = "${var.quorum_validator_instance_type}"
  user_data     = "${element(data.template_file.user_data_quorum_validator.*.rendered, count.index)}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${element(aws_iam_instance_profile.quorum_validator.*.name, count.index)}"
  security_groups      = ["${aws_security_group.quorum_validator.id}"]

  placement_tenancy = "${var.use_dedicated_validators ? "dedicated" : "default"}"

  root_block_device {
    volume_size = "${var.node_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "quorum_observer" {
  count = "${data.template_file.user_data_quorum_observer.count}"

  name_prefix = "quorum-network-${var.network_id}-observer-${count.index}-"

  image_id      = "${var.quorum_ami == "" ? data.aws_ami.quorum.id : var.quorum_ami}"
  instance_type = "${var.quorum_observer_instance_type}"
  user_data     = "${element(data.template_file.user_data_quorum_observer.*.rendered, count.index)}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${element(aws_iam_instance_profile.quorum_observer.*.name, count.index)}"
  security_groups      = ["${aws_security_group.quorum_observer.id}"]

  placement_tenancy = "${var.use_dedicated_observers ? "dedicated" : "default"}"

  root_block_device {
    volume_size = "${var.node_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AMI
# ---------------------------------------------------------------------------------------------------------------------
data "aws_ami" "quorum" {
  most_recent = true
  owners      = ["037794263736"]

  filter {
    name   = "name"
    values = ["eximchain-network-quorum-*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OUTPUT INSTANCES
# ---------------------------------------------------------------------------------------------------------------------
data "aws_instances" "quorum_maker_dns" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)>0 ? 1 : 0}"

  instance_tags {
    Name = "quorum-network-${var.network_id}-maker-*"
  }

  depends_on = ["aws_autoscaling_group.quorum_maker"]
}

data "aws_instance" "quorum_maker_node" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  instance_tags {
    Name = "quorum-network-${var.network_id}-maker-*"
  }
  instance_id = "${data.aws_instances.quorum_maker_dns.ids[count.index]}"

  depends_on = ["aws_autoscaling_group.quorum_maker", "data.aws_instances.quorum_maker_dns"]
}

data "aws_instances" "quorum_validator_dns" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)>0 ? 1 : 0}"

  instance_tags {
    Name = "quorum-network-${var.network_id}-validator-*"
  }

  depends_on = ["aws_autoscaling_group.quorum_validator"]
}

data "aws_instance" "quorum_validator_node" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  instance_tags {
    Name = "quorum-network-${var.network_id}-validator-*"
  }
  instance_id = "${data.aws_instances.quorum_validator_dns.ids[count.index]}"

  depends_on = ["aws_autoscaling_group.quorum_validator", "data.aws_instances.quorum_validator_dns"]
}

data "aws_instances" "quorum_observer_dns" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)>0 ? 1 : 0}"

  instance_tags {
    Name = "quorum-network-${var.network_id}-observer-*"
  }

  depends_on = ["aws_autoscaling_group.quorum_observer"]
}

data "aws_instance" "quorum_observer_node" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  instance_tags {
    Name = "quorum-network-${var.network_id}-observer-*"
  }
  instance_id = "${data.aws_instances.quorum_observer_dns.ids[count.index]}"

  depends_on = ["aws_autoscaling_group.quorum_observer", "data.aws_instances.quorum_observer_dns"]
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM OBSERVER ELASTIC IPs
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_eip" "quorum_observer" {
  count = "${var.use_elastic_observer_ips ? lookup(var.observer_node_counts, var.aws_region, 0) : 0}"
  vpc = true
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-makers-${count.index}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }]
}
EOF

lifecycle {
  create_before_destroy = true
}
}

resource "aws_iam_role" "quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-validators-${count.index}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }]
}
EOF

lifecycle {
  create_before_destroy = true
}
}

resource "aws_iam_role" "quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-observers-${count.index}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }]
}
EOF

lifecycle {
  create_before_destroy = true
}
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE IAM POLICY ATTACHMENT AND INSTANCE PROFILE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  role       = "${element(aws_iam_role.quorum_maker.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.quorum.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "quorum_maker" {
  count = "${lookup(var.maker_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-makers-${count.index}"
  role = "${element(aws_iam_role.quorum_maker.*.name, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  role       = "${element(aws_iam_role.quorum_validator.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.quorum.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "quorum_validator" {
  count = "${lookup(var.validator_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-validators-${count.index}"
  role = "${element(aws_iam_role.quorum_validator.*.name, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  role       = "${element(aws_iam_role.quorum_observer.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.quorum.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "quorum_observer" {
  count = "${lookup(var.observer_node_counts, var.aws_region, 0)}"

  name = "quorum-${var.aws_region}-network-${var.network_id}-observers-${count.index}"
  role = "${element(aws_iam_role.quorum_observer.*.name, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}
