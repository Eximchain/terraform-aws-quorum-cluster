provider "aws" {
    region = "us-east-1"
}

provider "archive" {}

resource "aws_key_pair" "public_key105" {
    key_name = "${var.key_name}"
    public_key = "${file("${var.key_path}")}"
}

# encrypt the private SSH key
resource "aws_kms_key" "a" {
  description = "Used for encrypting SSH keys on S3"
  # encrypt the SSH key
  provisioner "local-exec" {
    command = "aws kms encrypt --key-id ${aws_kms_key.a.id} --plaintext fileb://${var.private_ssh} --output text --query CiphertextBlob | base64 --decode > ${var.enc_ssh}"
  }
}

resource "aws_kms_grant" "a" {
  name              = "my-grant"
  key_id            = "${aws_kms_key.a.key_id}"
  grantee_principal = "${aws_iam_role.iam_for_lambda105.arn}"
  operations        = ["Encrypt", "Decrypt"]
}

resource "aws_s3_bucket" "b" {
  bucket_prefix = "${var.bucket_prefix}"
  force_destroy = "true"
}

resource "aws_vpc" "notify-vpc" {
  cidr_block = "${var.vpc_cidr_block}"
  tags {
    Name = "notify-vpc"
  }
}

resource "aws_s3_bucket" "notify_bucket" {
  bucket_prefix = "${var.notify_prefix}"
  force_destroy = "true"
  acl = "public-read-write"
}

# upload the encrypted SSH key to the S3 bucket
resource "aws_s3_bucket_object" "ssh_key" {
   depends_on = ["aws_kms_key.a", "aws_s3_bucket.b"]
   key = "${var.bucket_key}"
   bucket = "${aws_s3_bucket.b.id}"
   source = "${var.enc_ssh}"

   # and remove the encrypted file from the system
   provisioner "local-exec" {
     command = "rm ${var.enc_ssh}"
   }
}

// Bucket policy See https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy.html
resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.b.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "AllowLambdaAccessS3",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Principal": {
        "Service": "lambda.amazonaws.com",
        "Service": "autoscaling.amazonaws.com",
        "Service": "events.amazonaws.com"
      },
      "Resource": "${aws_s3_bucket.b.arn}/*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Principal": {
        "Service": "lambda.amazonaws.com",
        "Service": "autoscaling.amazonaws.com",
        "Service": "events.amazonaws.com"
      },
      "Resource": "${aws_s3_bucket.b.arn}",
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_object" "upgradesh" {
  bucket = "${aws_s3_bucket.b.id}"
  key = "${var.upgradesh_key}"
  source = "${var.upgrade_file}"
}

resource "aws_s3_bucket_object" "upgradezip" {
  bucket = "${aws_s3_bucket.b.id}"
  key = "${var.upgrade_zip_key}"
  source = "${var.upgrade_zip_file}"
}

resource "null_resource" "build" {
   provisioner "local-exec" {
     command = "GOOS=\"linux\" GOARCH=\"amd64\" GOPATH=\"$$(dirname $$(dirname `pwd`))\" go build -v eximchain.com/UpgradeLambda"
   }
}

data "archive_file" "zip" {
  depends_on  = ["null_resource.build"]
  type        = "zip"
  source_file = "${var.lambda_source_file}"
  output_path = "${var.lambda_output_path}"
}

# Declare the lambda function that will be launched
# This also creates a CloudWatch log group named  NotifyAutoscalingGroupLaunched
resource "aws_lambda_function" "lambda_code105" {
  filename         = "${data.archive_file.zip.output_path}"
  function_name    = "NotifyAutoscalingGroupLaunched"
  handler          = "UpgradeLambda" # Name of Go package after unzipping the filename above
  role             = "${aws_iam_role.iam_for_lambda105.arn}"
  runtime          = "go1.x"
  source_code_hash = "${data.archive_file.zip.output_sha}" # 
  timeout          = 300
}

resource "aws_sns_topic" "topic105" {
  name = "topic105"
}

resource "aws_sns_topic_subscription" "lambda105" {
  topic_arn = "${aws_sns_topic.topic105.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda_code105.arn}"
}

resource "aws_lambda_permission" "with_sns105-01" {
    statement_id = "AllowExecutionFromSNS105"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_code105.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.topic105.arn}"
}

resource "aws_lambda_permission" "with_sns105-02" {
    statement_id = "AllowExecutionFromAutoscaling105"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_code105.arn}"
    principal = "autoscaling.amazonaws.com"
    source_arn = "${aws_sns_topic.topic105.arn}"
}

# see https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html no 3
resource "aws_lambda_permission" "with_sns105-03" {
    statement_id = "AllowExecutionFromAutoscalingGroup105-01"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_code105.arn}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_sns_topic.topic105.arn}"
}

resource "aws_iam_role" "iam_for_lambda105" {
  name = "iam_for_lambda"
# See also https://aws.amazon.com/blogs/compute/easy-authorization-of-aws-lambda-functions/
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com",
        "Service": "autoscaling.amazonaws.com",
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

resource "aws_iam_role_policy_attachment" "sns_access105" {
   role = "${aws_iam_role.iam_for_lambda105.name}"
   policy_arn = "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"
}

resource "aws_iam_policy" "lambda_logging105" {
  name = "lambda_logging105"
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

resource "aws_iam_policy" "lambda_ec2-105" {
  name = "lambda_access_ec2-105"
  path = "/"
  description = "IAM policy for accessing EC2 functions from Lambda"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_sns105" {
  name = "lambda_sns105"
  path = "/"
  description = "IAM policy for SNS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:*",
        "autoscaling:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

// The first statement allows access to all items underneath the bucket
// The second statement allows access to the bucket
resource "aws_iam_policy" "lamba_s3-105" {
    name = "lambda_s3-105"
    path = "/"
    description = "IAM policy for S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Resource": "${aws_s3_bucket.b.arn}/*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:*"
      ],
      "Resource": "${aws_s3_bucket.b.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_ses105" {
  name = "lambda_ses105"
  path = "/"
  description = "IAM policy for SES"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ses:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logging105" {
   role = "${aws_iam_role.iam_for_lambda105.name}"
   policy_arn = "${aws_iam_policy.lambda_logging105.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_sns105" {
   role = "${aws_iam_role.iam_for_lambda105.name}"
   policy_arn = "${aws_iam_policy.lambda_sns105.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_ses" {
   role = "${aws_iam_role.iam_for_lambda105.name}"
   policy_arn = "${aws_iam_policy.lambda_ses105.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_ec2" {
   role = "${aws_iam_role.iam_for_lambda105.name}"
   policy_arn = "${aws_iam_policy.lambda_ec2-105.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_s3-105" {
   role = "${aws_iam_role.iam_for_lambda105.name}"
   policy_arn = "${aws_iam_policy.lamba_s3-105.arn}"
}

# 
resource "aws_sns_topic" "download_completed" {
  name = "s3-event-notify-download-completed"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:s3-event-notification-topic",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.notify_bucket.arn}"}
        }
    }]
}
POLICY
}


resource "aws_launch_template" "eximchain105" {
  name_prefix = "eximchain105-"
  image_id = "ami-4be75934"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.public_key105.key_name}"
}

resource "aws_autoscaling_group" "exc105" {
// this is not required within here unless initial_lifecycle_hook is added
    depends_on = ["aws_iam_role_policy_attachment.lambda_ec2", "aws_iam_role_policy_attachment.lambda_ses",
        "aws_iam_role_policy_attachment.lambda_sns105", "aws_iam_role_policy_attachment.lambda_logging105", 
        "aws_iam_role.iam_for_lambda105", "aws_launch_template.eximchain105"]   
    health_check_grace_period = 400
    health_check_type = "EC2"
    availability_zones = ["us-east-1a"]
    desired_capacity = 1
    max_size = 4
    min_size = 1
    wait_for_capacity_timeout = "11m"

    initial_lifecycle_hook {
        name = "eximchainlch102"
        default_result = "CONTINUE"
        heartbeat_timeout = 2000
        lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
        notification_target_arn = "${aws_sns_topic.topic105.arn}"
        role_arn = "${aws_iam_role.iam_for_lambda105.arn}"
        notification_metadata = <<EOF
{
  "bucket-name": "${aws_s3_bucket.b.id}",
  "bucket-key": "${aws_s3_bucket_object.ssh_key.key}",
  "${var.ssh_username}": "${var.ssh_usernamevalue}",
  "${var.upgrade_cmd}": "${var.upgrade_cmd_value}",
  "${var.upgrade_location}": "${var.upgrade_location_value}",
  "security-group": "somename",
  "vpc": "${aws_vpc.notify-vpc.id}",
  "upgrade.zip": "upgrade.zip"
}
EOF
    }

    launch_template = {
        id = "${aws_launch_template.eximchain105.id}"
        version = "$$Latest"
    }
}

output "kms id" {
  value = "${aws_kms_key.a.id}"
}

output "bucket id" {
  value = "${aws_s3_bucket.b.id}"
}


