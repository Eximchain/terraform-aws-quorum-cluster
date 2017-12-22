# ---------------------------------------------------------------------------------------------------------------------
# QUORUM MAKER NODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "quorum_maker_node" {
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.quorum_node_instance_type}"

  count = "${var.num_maker_nodes}"

  ami = "${lookup(var.quorum_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_quorum.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.quorum_node.name}"

  vpc_security_group_ids = ["${aws_security_group.quorum.id}"]

  subnet_id = "${aws_subnet.default.id}"

  tags {
    Name = "quorum-maker-node-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${count.index}' | sudo tee /opt/quorum/info/role-index.txt",
      "echo '${count.index}' | sudo tee /opt/quorum/info/overall-index.txt",
      "echo '${var.num_maker_nodes + var.num_validator_nodes + var.num_observer_nodes}' | sudo tee /opt/quorum/info/network-size.txt",
      "echo '${var.num_maker_nodes}' | sudo tee /opt/quorum/info/num-makers.txt",
      "echo '${var.num_validator_nodes}' | sudo tee /opt/quorum/info/num-validators.txt",
      "echo 'maker' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.bootnode_cluster_size}' | sudo tee /opt/quorum/info/num-bootnodes.txt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM VALIDATOR NODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "quorum_validator_node" {
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.quorum_node_instance_type}"

  count = "${var.num_validator_nodes}"

  ami = "${lookup(var.quorum_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_quorum.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.quorum_node.name}"

  vpc_security_group_ids = ["${aws_security_group.quorum.id}"]

  subnet_id = "${aws_subnet.default.id}"

  tags {
    Name = "quorum-validator-node-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${count.index}' | sudo tee /opt/quorum/info/role-index.txt",
      "echo '${var.num_maker_nodes + count.index}' | sudo tee /opt/quorum/info/overall-index.txt",
      "echo '${var.num_maker_nodes + var.num_validator_nodes + var.num_observer_nodes}' | sudo tee /opt/quorum/info/network-size.txt",
      "echo '${var.num_maker_nodes}' | sudo tee /opt/quorum/info/num-makers.txt",
      "echo '${var.num_validator_nodes}' | sudo tee /opt/quorum/info/num-validators.txt",
      "echo 'validator' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.bootnode_cluster_size}' | sudo tee /opt/quorum/info/num-bootnodes.txt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM OBSERVER NODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "quorum_observer_node" {
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.quorum_node_instance_type}"

  count = "${var.num_observer_nodes}"

  ami = "${lookup(var.quorum_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_quorum.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.quorum_node.name}"

  vpc_security_group_ids = ["${aws_security_group.quorum.id}"]

  subnet_id = "${aws_subnet.default.id}"

  tags {
    Name = "quorum-observer-node-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${count.index}' | sudo tee /opt/quorum/info/role-index.txt",
      "echo '${var.num_maker_nodes + var.num_validator_nodes + count.index}' | sudo tee /opt/quorum/info/overall-index.txt",
      "echo '${var.num_maker_nodes + var.num_validator_nodes + var.num_observer_nodes}' | sudo tee /opt/quorum/info/network-size.txt",
      "echo '${var.num_maker_nodes}' | sudo tee /opt/quorum/info/num-makers.txt",
      "echo '${var.num_validator_nodes}' | sudo tee /opt/quorum/info/num-validators.txt",
      "echo 'observer' | sudo tee /opt/quorum/info/role.txt",
      "echo '${var.vote_threshold}' | sudo tee /opt/quorum/info/vote-threshold.txt",
      "echo '${var.bootnode_cluster_size}' | sudo tee /opt/quorum/info/num-bootnodes.txt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# BOOTNODES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "bootnode" {
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.bootnode_instance_type}"

  count = "${var.bootnode_cluster_size}"

  ami = "${lookup(var.bootnode_amis, var.aws_region)}"
  user_data = "${data.template_file.user_data_quorum.rendered}"

  key_name = "${aws_key_pair.auth.id}"

  iam_instance_profile = "${aws_iam_instance_profile.quorum_node.name}"

  vpc_security_group_ids = ["${aws_security_group.quorum.id}"]

  subnet_id = "${aws_subnet.default.id}"

  tags {
    Name = "bootnode-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "echo '${count.index}' | sudo tee /opt/quorum/info/index.txt",
      "echo '${var.num_maker_nodes + var.num_validator_nodes + var.num_observer_nodes}' | sudo tee /opt/quorum/info/network-size.txt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH QUORUM NODE WHEN IT'S BOOTING
# This script will configure and start the Consul Agent
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_quorum" {
  template = "${file("${path.module}/user-data/user-data-quorum.sh")}"

  vars {
    consul_cluster_tag_key   = "${module.consul_cluster.cluster_tag_key}"
    consul_cluster_tag_value = "${module.consul_cluster.cluster_tag_value}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "quorum" {
  name        = "quorum_nodes"
  description = "Used for quorum nodes"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Constellation access from self
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    self = true
  }

  # Quorum access from self
  ingress {
    from_port   = 21000
    to_port     = 21000
    protocol    = "tcp"
    self = true
  }

  # Quorum access from self to rpc port
  ingress {
    from_port   = 22000
    to_port     = 22000
    protocol    = "tcp"
    self = true
  }

  # Bootnode udp access from self
  ingress {
    from_port   = 30301
    to_port     = 30301
    protocol    = "udp"
    self = true
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "quorum_node" {
    name = "quorum-node"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE IAM POLICY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "quorum_node" {
    name = "quorum-node-policy"
    description = "A policy for quorum nodes"
    policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [{
      "Effect": "Allow",
      "Action": [
         "ec2:DescribeInstances",
         "ec2:DescribeImages",
         "ec2:DescribeTags",
         "ec2:DescribeSnapshots"
      ],
      "Resource": "*"
   }
   ]
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM NODE IAM POLICY ATTACHMENT AND INSTANCE PROFILE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "quorum_node" {
    role = "${aws_iam_role.quorum_node.name}"
    policy_arn = "${aws_iam_policy.quorum_node.arn}"
}

resource "aws_iam_instance_profile" "quorum_node" {
    name = "quorum-node"
    role = "${aws_iam_role.quorum_node.name}"
}
