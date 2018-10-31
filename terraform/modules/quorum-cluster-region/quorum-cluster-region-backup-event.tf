
# This is to be placed in quorum-cluster-region

provider "archive" {}
provider "random" {}
provider "null" {}

data "local_file" "private_key" {
  filename = "${var.private_key_path}"
}

resource "aws_s3_bucket_object" "object" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  depends_on = ["data.aws_kms_ciphertext.EncryptSSHKey", "local_file.EncryptedSSHKey"]
  bucket = "${aws_s3_bucket.quorum_backup.id}"
  key    = "${var.enc_ssh_key}"
  source = "${var.enc_ssh_path}-${var.aws_region}"
}

resource "aws_sns_topic" "BackupEvent" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  name_prefix = "BackupLambda-${var.network_id}-${var.aws_region}-"
}

resource "aws_cloudwatch_event_rule" "BackupTimer" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  name_prefix = "BackupLambda-${var.network_id}-${var.aws_region}-" 
  schedule_expression = "${var.backup_interval}"
}

resource "aws_cloudwatch_event_target" "sns" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"  
  rule      = "${aws_cloudwatch_event_rule.BackupTimer.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.BackupEvent.arn}"
}

resource "aws_sns_topic_subscription" "BackupLambda" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  topic_arn = "${aws_sns_topic.BackupEvent.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.BackupLambda.arn}"
}

# Allow the SNS to trigger the backup lambda
resource "aws_lambda_permission" "BackupLambda" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  statement_id = "AllowExecutionFromSNS-BackupLambda-${var.network_id}-${var.aws_region}"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.BackupLambda.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.BackupEvent.arn}"
}

resource "aws_sns_topic_policy" "default" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  arn    = "${aws_sns_topic.BackupEvent.arn}"
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.BackupEvent.arn}"]
  }
}


resource "aws_security_group_rule" "quorum_maker_https" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"

  security_group_id = "${aws_security_group.quorum_maker.id}"
  type              = "egress"

  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

# Declare the Backup Lambda
# Lambdas are by default in a VPC
resource "aws_lambda_function" "BackupLambda" {
    count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
    depends_on = ["aws_s3_bucket.quorum_backup", "aws_nat_gateway.VPCMakerAccess",
    "data.archive_file.BackupLambda"]
    filename         = "${var.aws_region}-${var.BackupLambda_output_path}"
    function_name    = "BackupLambda-${var.network_id}-${var.aws_region}"
    handler          = "BackupLambda" # Name of Go package after unzipping the filename above
    role             = "${aws_iam_role.iam_for_BackupLambda.arn}"
    runtime          = "go1.x"
    source_code_hash = "${sha256("file(${var.aws_region}-${var.BackupLambda_output_path})")}" # 
    timeout          = 300

    vpc_config {
       subnet_ids = ["${aws_subnet.BackupLambdaAccessInternet.id}"]
       security_group_ids = ["${aws_security_group.allow_all.*.id}"]
    }

    environment {
        variables = {
            NetworkId = "${var.network_id}"
            Bucket = "${aws_s3_bucket.quorum_backup.id}"
            Key = "${var.enc_ssh_key}"
            SSHUser = "ubuntu"
        }
    }
}

// "

resource "aws_iam_role" "iam_for_BackupLambda" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  name = "iam_for_BackupLambda-${var.network_id}-${var.aws_region}"
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

resource "aws_iam_policy" "BackupLamba_Permissions" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  path = "/"
  description = "IAM policy for accesing EC2 and S3 buckets from Lambda"
  policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "BackupLambda1" {
   count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
   role = "${aws_iam_role.iam_for_BackupLambda.name}"
   policy_arn = "${aws_iam_policy.BackupLamba_Permissions.arn}"
}


resource "aws_iam_policy" "BackupLambda_logging" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  name = "BackupLambda-${var.network_id}-${var.aws_region}"
  path = "/"
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

resource "aws_iam_role_policy_attachment" "BackupLambda2" {
   count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
   role = "${aws_iam_role.iam_for_BackupLambda.name}"
   policy_arn = "${aws_iam_policy.BackupLambda_logging.arn}"
}

# Zip the Backup Lambda
resource "null_resource" "BackupLambda" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  triggers {
    main = "${sha256(file("${var.BackupLambda_source_file}"))}"
  }
  # destroy
  provisioner "local-exec" {
    when = "destroy"
    command = "rm ${var.aws_region}-${var.BackupLambda_output_path}"
    on_failure = "continue"
  }
  // # creat
  // provisioner "local-exec" {
  //   command = "zip -j ${var.aws_region}-${var.BackupLambda_output_path} ${var.BackupLambda_source_file}"
  // }
  # the creation is in "archive_file" "BackupLambda"
}

data "archive_file" "BackupLambda" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  type        = "zip"
  source_file  = "${var.BackupLambda_source_file}"
  output_path = "${var.aws_region}-${var.BackupLambda_output_path}"
  depends_on = ["null_resource.BackupLambda"]
}

resource "aws_kms_key" "a" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  description = "Used for encrypting SSH keys on S3"
  tags {
     name = "BackupLambda-${var.network_id}-${var.aws_region}-KMS"
  }
}

output "aws_kms_key_test" {
  value = "${aws_kms_key.a.*.id}"
}

# Encrypt the contents of the file located at var.private_key_path
data "aws_kms_ciphertext" "EncryptSSHKey" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  key_id = "${aws_kms_key.a.id}"  
  plaintext = "${file("${var.private_key_path}")}"
}

# Save the encrypted contents to the file specified at filename
resource "local_file" "EncryptedSSHKey" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  content = "${base64decode("${data.aws_kms_ciphertext.EncryptSSHKey.ciphertext_blob}")}"
  filename = "${var.enc_ssh_path}-${var.aws_region}"
}

resource "aws_kms_grant" "a" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  name              = "kms-grant-${var.network_id}-${var.aws_region}"
  key_id            = "${aws_kms_key.a.key_id}"
  grantee_principal = "${aws_iam_role.iam_for_BackupLambda.arn}"
  operations        = ["Encrypt", "Decrypt"]
}

output "aws_s3_bucket" {
  value = "${element(concat(aws_s3_bucket.quorum_backup.*.id, list("")), 0)}"
}

resource "aws_security_group" "allow_all" {
    count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
    name        = "BackupLambdaSSH-${var.network_id}-${var.aws_region}-allow_all"
    description = "Allow all outgoing traffic"
    vpc_id = "${aws_vpc.quorum_cluster.id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all traffic"
    }
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all SSH traffic"
    }
  tags {
     name = "BackupLambda-${var.network_id}-${var.aws_region}-SG"
  }
}

// use the next value after data.template_file.quorum_observer_cidr_block
data "template_file" "quorum_maker_cidr_block_lambda" {
  template = "$${cidr_block}"

  vars {
    cidr_block = "${cidrsubnet(data.template_file.quorum_cidr_block.rendered, 2, 3)}"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web1" {
  count = "${var.aws_region =="us-east-1" ?1:0}"
  source_dest_check = false
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "quorum-cluster-${var.aws_region}-network-${var.network_id}"
  subnet_id = "${aws_subnet.BackupLambdaAccessInternet.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.*.id}"]
  tags {
    Name = "quorum-network-${var.network_id}-BackupLambda-NAT-check-1"
    subnet_id = "BackupLambdaAccessInternet-${aws_subnet.BackupLambdaAccessInternet.id}"
  }
}

resource "aws_subnet" "BackupLambdaAccessInternet" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  vpc_id                  = "${aws_vpc.quorum_cluster.id}"
  availability_zone       = "${lookup(var.az_override, var.aws_region, "") == "" ? element(data.aws_availability_zones.available.names, count.index) : element(split(",", lookup(var.az_override, var.aws_region, "")), count.index)}"
  cidr_block              = "${cidrsubnet(data.template_file.quorum_maker_cidr_block_lambda.rendered, 3, count.index)}"
  tags {
    Name      = "quorum-network-${var.network_id}-BackupLambda-NAT"
    NodeType  = "BackupLambda"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

resource "aws_eip" "gw1" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  vpc = true
  depends_on = ["aws_internet_gateway.quorum_cluster"]
  tags {
    Name      = "quorum-network-${var.network_id}-BackupLambda"
    NodeType  = "BackupLambda-EIP"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

resource "aws_nat_gateway" "VPCMakerAccess" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  allocation_id = "${aws_eip.gw1.0.id}"
  subnet_id = "${aws_subnet.quorum_maker.0.id}"
  depends_on = ["aws_internet_gateway.quorum_cluster"]
  tags {
    Name      = "quorum-network-${var.network_id}-BackupLambda-NAT"
    NodeType  = "NAT"
    NetworkId = "${var.network_id}"
    Region    = "${var.aws_region}"
  }
}

data "aws_ami" "nat" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }
  owners = ["amazon"]
}

resource "aws_route_table" "BackupLambdaRouteTable" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  vpc_id = "${aws_vpc.quorum_cluster.id}"
  tags {
     Name = "BackupLambdaSSH-${var.network_id}-${var.aws_region}-RouteTable"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.VPCMakerAccess.0.id}"
  }
}

resource "aws_route_table_association" "BackupLambdaRouteAssociation" {
  count = "${signum(lookup(var.maker_node_counts, var.aws_region, 0))}"
  subnet_id      = "${aws_subnet.BackupLambdaAccessInternet.id}"
  route_table_id = "${aws_route_table.BackupLambdaRouteTable.id}" 
}
