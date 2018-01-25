# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "vault_amis" {
  description = "A mapping from AWS region to AMI to use for vault in that region."
  type        = "map"
}

variable "cert_owner" {
  description = "The OS user to be made the owner of the local copy of the vault certificates. Should usually be set to the user operating the tool."
}

variable "aws_key_pair_id" {
  description = "The ID of the AWS key pair to SSH into your instances"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "vault_port" {
  description = "The port that vault will be accessible on."
  default     = 8200
}

variable "force_destroy_s3_bucket" {
  description = "Whether or not to force destroy the vault s3 bucket. Set to true for an easily destroyed test environment. DO NOT set to true for a production environment."
  default     = false
}

variable "vault_cluster_size" {
  description = "The number of instances in the vault cluster"
  default     = 3
}

variable "vault_instance_type" {
  description = "The type of instance to use in the vault cluster"
  default     = "t2.micro"
}

variable "consul_cluster_size" {
  description = "The number of instances in the consul cluster"
  default     = 3
}

variable "consul_instance_type" {
  description = "The type of instance to use in the consul cluster"
  default     = "t2.micro"
}

variable "network_id" {
  description = <<DESCRIPTION
Ethereum network ID, also used in naming some resources for uniqueness.
Must be unique amongst networks in the same AWS account and launched with this tool.
Ideally is globally unique amongst ethereum and quorum networks.
DESCRIPTION
  default = 64813
}

variable "lb_ssl_policy" {
  description = "The SSL policy to use for the vault load balancer"
  default     = "ELBSecurityPolicy-2016-08"
}

variable "cert_org_name" {
  description = "The organization to associate with the vault certificates."
  default     = "Example Co."
}

variable "aws_azs" {
  description = "Mapping from AWS region to AZs to utilize in that region."
  type        = "map"
  default     = {
    # Virginia
    us-east-1      = ["us-east-1a", "us-east-1b", "us-east-1c"]
    # Ohio
    us-east-2      = ["us-east-2a", "us-east-2b", "us-east-2c"]
    # California
    us-west-1      = ["us-west-1a", "us-west-1b", "us-west-1c"]
    # Oregon
    us-west-2      = ["us-west-2a", "us-west-2b", "us-west-2c"]
    # Frankfurt
    eu-central-1   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    # Ireland
    eu-west-1      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    # London
    eu-west-2      = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
    # Paris
    eu-west-3      = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
    # Mumbai
    ap-south-1     = ["ap-south-1a", "ap-south-1b"]
    # Tokyo
    ap-northeast-1 = ["ap-northeast-1a", "ap-northeast-1b", "ap-northeast-1c"]
    # Seoul
    ap-northeast-2 = ["ap-northeast-1a", "ap-northeast-1b"]
    # Singapore
    ap-southeast-1 = ["ap-southeast-1a", "ap-southeast-1b"]
    # Sydney
    ap-southeast-2 = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    # Canada
    ca-central-1   = ["ca-central-1a", "ca-central-1b"]
    # South America
    sa-east-1      = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
  }
}
