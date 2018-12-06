provider "archive" {version = "~> 1.1"}
provider "local" {version = "~> 1.1"}
provider "null" {version = "~> 1.0"}
provider "random" {version = "~> 2.0"}

data "local_file" "backup_lambda_ssh_private_key" {
  count = "${var.backup_enabled && var.backup_lambda_ssh_private_key == "" ? 1 : 0}"

  filename = "${var.backup_lambda_ssh_private_key_path}"
}

resource "aws_s3_bucket_object" "encrypted_ssh_key" {
  count      = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"
  
  bucket     = "${aws_s3_bucket.quorum_backup.id}"
  key        = "${var.enc_ssh_key}"
  
  content_base64 = "${data.aws_kms_ciphertext.encrypt_ssh_operation.ciphertext_blob}"

  depends_on = ["data.aws_kms_ciphertext.encrypt_ssh_operation"]
}

resource "aws_sns_topic" "backup_event" {
  count       = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  name_prefix = "BackupLambda-${var.network_id}-${var.aws_region}-"
}

resource "aws_cloudwatch_event_rule" "backup_timer" {
  count               = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  name_prefix         = "BackupLambda-${var.network_id}-${var.aws_region}-" 
  schedule_expression = "${var.backup_interval}"
}

resource "aws_cloudwatch_event_target" "sns" {
  count     = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"  

  rule      = "${aws_cloudwatch_event_rule.backup_timer.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.backup_event.arn}"
}

resource "aws_sns_topic_subscription" "backup_lambda" {
  count     = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  topic_arn = "${aws_sns_topic.backup_event.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.backup_lambda.arn}"
}

# Allow the SNS to trigger the backup lambda
resource "aws_lambda_permission" "backup_lambda" {
  count         = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  statement_id  = "AllowExecutionFromSNS-BackupLambda-${var.network_id}-${var.aws_region}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.backup_lambda.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.backup_event.arn}"
}

resource "aws_sns_topic_policy" "default" {
  count  = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  arn    = "${aws_sns_topic.backup_event.arn}"
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.backup_event.arn}"]
  }
}

# Declare the Backup Lambda
# Lambdas are by default in a VPC
resource "aws_lambda_function" "backup_lambda" {
    count            = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

    filename         = "${local.temp_lambda_zip_path}"
    function_name    = "BackupLambda-${var.network_id}-${var.aws_region}"
    handler          = "${var.backup_lambda_binary}" # Name of Go package after unzipping the filename above
    role             = "${aws_iam_role.backup_lambda.arn}"
    runtime          = "go1.x"
    source_code_hash = "${sha256("file(${local.temp_lambda_zip_path})")}" # 
    timeout          = 300

    vpc_config {
       subnet_ids         = ["${aws_subnet.backup_lambda.id}"]
       security_group_ids = ["${aws_security_group.allow_all_for_backup_lambda.*.id}"]
    }

    environment {
        variables {
            NetworkId = "${var.network_id}"
            Bucket    = "${aws_s3_bucket.quorum_backup.id}"
            Key       = "${var.enc_ssh_key}"
            SSHUser   = "ubuntu"
        }
    }

    depends_on       = ["aws_s3_bucket.quorum_backup", "aws_nat_gateway.backup_lambda",
    "null_resource.fetch_backup_lambda_zip"]
}

resource "aws_iam_role" "backup_lambda" {
  count = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  name  = "iam_for_backup_lambda-${var.network_id}-${var.aws_region}"
# See also https://aws.amazon.com/blogs/compute/easy-authorization-of-aws-lambda-functions/
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com",
        "Service": "events.amazonaws.com",
        "Service": "sns.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "backup_lambda_permissions" {
  count       = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  path        = "/"
  description = "IAM policy for accesing EC2 and S3 buckets from Lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": ["s3:*"],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.quorum_backup.arn}",
        "${aws_s3_bucket.quorum_backup.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_backup_lambda_access_s3_and_ec2_resources" {
   count      = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

   role       = "${aws_iam_role.backup_lambda.name}"
   policy_arn = "${aws_iam_policy.backup_lambda_permissions.arn}"
}


resource "aws_iam_policy" "allow_backup_lambda_logging" {
  count       = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  name        = "BackupLambda-${var.network_id}-${var.aws_region}"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "null_resource" "mkdir_temp" {
  triggers { always="${uuid()}" }
  provisioner "local-exec" {
    command = <<EOT
  mkdir -p ${path.module}/tmp/
EOT
  }
  provisioner "local-exec" {
    when = "destroy"
    command = "rm -rf ${path.module}/tmp"
    on_failure = "continue"
  }
}

resource "aws_iam_role_policy_attachment" "allow_backup_lambda_logging" {
   count      = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

   role       = "${aws_iam_role.backup_lambda.name}"
   policy_arn = "${aws_iam_policy.allow_backup_lambda_logging.arn}"
}

locals {
  temp_lambda_zip_path = "${path.module}/tmp/${var.aws_region}-${var.backup_lambda_output_path}"
}

resource "null_resource" "fetch_backup_lambda_zip" {
  count = "${var.backup_enabled ? 1 : 0}"

  triggers { always="${uuid()}" }
  provisioner "local-exec" {
     command = <<EOT
if [ ! -e ${local.temp_lambda_zip_path} ]; then 
   wget -O ${local.temp_lambda_zip_path} ${var.backup_lambda_binary_url}
fi
EOT
  }
  provisioner "local-exec" {
    when = "destroy"
    command = "rm ${local.temp_lambda_zip_path}"
    on_failure = "continue"
  }

  depends_on = ["null_resource.mkdir_temp"]
}

resource "aws_kms_key" "ssh_encryption_key" {
  count       = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  description = "Used for encrypting SSH keys on S3"

  tags {
     name = "BackupLambda-${var.network_id}-${var.aws_region}-KMS"
  }
}

# Encrypt the contents of the SSH key
data "aws_kms_ciphertext" "encrypt_ssh_operation" {
  count     = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  key_id    = "${aws_kms_key.ssh_encryption_key.id}"  
  plaintext = "${var.backup_lambda_ssh_private_key}"
}

resource "aws_kms_grant" "backup_lambda" {
  count             = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  name              = "kms-grant-${var.network_id}-${var.aws_region}"
  key_id            = "${aws_kms_key.ssh_encryption_key.key_id}"
  grantee_principal = "${aws_iam_role.backup_lambda.arn}"
  operations        = ["Encrypt", "Decrypt"]
}

resource "aws_security_group" "allow_all_for_backup_lambda" {
  count       = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  name        = "BackupLambdaSSH-${var.network_id}-${var.aws_region}-allow_all_outgoing"
  description = "Allow all outgoing traffic for BackupLambda"
  vpc_id      = "${aws_vpc.quorum_cluster.id}"

  tags {
     name = "BackupLambda-${var.network_id}-${var.aws_region}-SG"
  }
}

resource "aws_security_group_rule" "allow_all_outgoing_for_backup_lambda" {
  count       = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow_all_for_backup_lambda.0.id}"
}

resource "aws_security_group_rule" "allow_ssh_incoming_for_debugging" {
  count       = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow_all_for_backup_lambda.0.id}"
}

// use the next value after data.template_file.quorum_observer_cidr_block
data "template_file" "quorum_maker_cidr_block_lambda" {
  count = "${var.backup_enabled ? 1 : 0}"

  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(data.template_file.quorum_cidr_block.rendered, 2, 3)}"
  }
}

resource "aws_subnet" "backup_lambda" {
  count              = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  vpc_id             = "${aws_vpc.quorum_cluster.id}"
  availability_zone  = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(split(",", lookup(var.az_override, var.aws_region, "")), count.index)}"
  cidr_block         = "${cidrsubnet(data.template_file.quorum_backup_lambda_cidr_block.rendered, 3, count.index)}"

  tags {
    Name      = "quorum-network-${var.network_id}-BackupLambda-NAT"
    NodeType  = "BackupLambda"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

resource "aws_eip" "gateway_ip" {
  count      = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  vpc        = true

  tags {
    Name      = "quorum-network-${var.network_id}-BackupLambda"
    NodeType  = "BackupLambda-EIP"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }

  depends_on = ["aws_internet_gateway.quorum_cluster"]
}

resource "aws_nat_gateway" "backup_lambda" {
  count         = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  allocation_id = "${aws_eip.gateway_ip.0.id}"
  subnet_id     = "${aws_subnet.backup_lambda.0.id}"
 
  tags {
    Name      = "quorum-network-${var.network_id}-BackupLambda-NAT"
    NodeType  = "NAT"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }

  depends_on    = ["aws_internet_gateway.quorum_cluster"]
}

resource "aws_route_table" "backup_lambda" {
  count  = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  vpc_id = "${aws_vpc.quorum_cluster.id}"

  tags {
     Name = "BackupLambdaSSH-${var.network_id}-${var.aws_region}-RouteTable"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.quorum_cluster.id}"
  }
}

resource "aws_route_table_association" "backup_lambda" {
  count          = "${var.backup_enabled ? signum(lookup(var.maker_node_counts, var.aws_region, 0) + lookup(var.observer_node_counts, var.aws_region, 0) + lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"

  subnet_id      = "${aws_subnet.backup_lambda.0.id}"
  route_table_id = "${aws_route_table.backup_lambda.id}" 
}

# Help debug all 3 subnets
// resource "aws_instance" "validator" {
//   count          = "${var.backup_enabled ? signum(lookup(var.validator_node_counts, var.aws_region, 0)) : 0}"
//   ami           = "${data.aws_ami.bootnode.id}"
//   instance_type = "t2.micro"

//   tags {
//     Name = "Debug-Validator"
//   }

//   key_name = "quorum-cluster-${var.aws_region}-network-${var.network_id}"
//   subnet_id = "${aws_subnet.quorum_validator.0.id}"
//   vpc_security_group_ids = ["${aws_security_group.allow_all_for_backup_lambda.0.id}", 
//     "${aws_security_group.allow_ssh_for_debugging.0.id}"]
// }

// data "aws_ami" "ubuntu" {
//   most_recent = true

//   filter {
//     name   = "name"
//     values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
//   }

//   filter {
//     name   = "virtualization-type"
//     values = ["hvm"]
//   }

//   owners = ["099720109477"] # Canonical
// }

// resource "aws_instance" "backup_lambda" {
//   count = "${var.aws_region =="us-east-1" ?1:0}"
//   source_dest_check = false
//   associate_public_ip_address = true
//   ami           = "${data.aws_ami.ubuntu.id}"
//   instance_type = "t2.micro"
//   key_name = "quorum-cluster-${var.aws_region}-network-${var.network_id}"
//   subnet_id = "${aws_subnet.backup_lambda.id}"
//   vpc_security_group_ids = ["${aws_security_group.allow_all_for_backup_lambda.*.id}"]
//   tags {
//     Name = "quorum-network-${var.network_id}-BackupLambda-NAT-backup_lambda-1"
//     subnet_id = "BackupLambdaAccessInternet-${aws_subnet.backup_lambda.id}"
//   }
// }

// resource "aws_instance" "observer" {
//   count = "${var.aws_region =="us-east-1" && lookup(var.observer_node_counts, var.aws_region, 0) > 0?1:0}"
//   source_dest_check = false
//   associate_public_ip_address = true
//   ami           = "${data.aws_ami.ubuntu.id}"
//   instance_type = "t2.micro"
//   key_name = "quorum-cluster-${var.aws_region}-network-${var.network_id}"
//   subnet_id = "${aws_subnet.quorum_observer.0.id}"
//   vpc_security_group_ids = ["${aws_security_group.allow_all_for_backup_lambda.*.id}"]
//   tags {
//     Name = "quorum-network-${var.network_id}-BackupLambda-NAT-observer-1"
//     subnet_id = "BackupLambdaAccessInternet-${aws_subnet.quorum_observer.0.id}"
//   }
// }

// resource "aws_instance" "validator" {
//   count = "${var.aws_region =="us-east-1" && lookup(var.validator_node_counts, var.aws_region, 0)>0?1:0}"
//   source_dest_check = false
//   associate_public_ip_address = true
//   ami           = "${data.aws_ami.ubuntu.id}"
//   instance_type = "t2.micro"
//   key_name = "quorum-cluster-${var.aws_region}-network-${var.network_id}"
//   subnet_id = "${aws_subnet.quorum_validator.0.id}"
//   vpc_security_group_ids = ["${aws_security_group.allow_all_for_backup_lambda.*.id}"]
//   tags {
//     Name = "quorum-network-${var.network_id}-BackupLambda-NAT-validator-1"
//     subnet_id = "BackupLambdaAccessInternet-${aws_subnet.quorum_validator.0.id}"
//   }
// }

// resource "aws_instance" "maker" {
//   count = "${var.aws_region =="us-east-1" && lookup(var.maker_node_counts, var.aws_region, 0)>0?1:0}"
//   source_dest_check = false
//   associate_public_ip_address = true
//   ami           = "${data.aws_ami.ubuntu.id}"
//   instance_type = "t2.micro"
//   key_name = "quorum-cluster-${var.aws_region}-network-${var.network_id}"
//   subnet_id = "${aws_subnet.quorum_maker.0.id}"
//   vpc_security_group_ids = ["${aws_security_group.allow_all_for_backup_lambda.*.id}"]
//   tags {
//     Name = "quorum-network-${var.network_id}-BackupLambda-NAT-maker-1"
//     subnet_id = "BackupLambdaAccessInternet-${aws_subnet.quorum_maker.0.id}"
//   }
// }
