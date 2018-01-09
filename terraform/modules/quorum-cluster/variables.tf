variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "private_key_path" {
  description = "Path to SSH private key corresponding to the public key in public_key_path"
}

variable "cert_owner" {
  description = "The OS user to be made the owner of the local copy of the vault certificates. Should usually be set to the user operating the tool."
}

variable "cert_org_name" {
  description = "The organization to associate with the vault certificates."
  default = "Example Co."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "network_id" {
  description = <<DESCRIPTION
Ethereum network ID, also used in naming some resources for uniqueness.
Must be unique amongst networks in the same AWS account and launched with this tool.
Ideally is globally unique amongst ethereum and quorum networks.
DESCRIPTION
  default = 64813
}

variable "force_destroy_s3_buckets" {
  description = "Whether or not to force destroy s3 buckets. Set to true for an easily destroyed test environment. DO NOT set to true for a production environment."
  default     = false
}

variable "quorum_azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type        = "list"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "quorum_amis" {
  type = "map"
}

variable "vault_amis" {
  type = "map"
}

variable "bootnode_amis" {
  type = "map"
}

variable "vault_cluster_size" {
  default = 3
}

variable "vault_instance_type" {
  default = "t2.micro"
}

variable "consul_cluster_size" {
  default = 3
}

variable "consul_instance_type" {
  default = "t2.micro"
}

variable "bootnode_cluster_size" {
  default = 1
}

variable "bootnode_instance_type" {
  default = "t2.small"
}

variable "quorum_node_instance_type" {
  default = "t2.small"
}

variable "num_maker_nodes" {
  description = "The number of maker nodes in the quorum cluster"
}

variable "num_validator_nodes" {
  description = "The number of validator nodes in the quorum cluster"
}

variable "num_observer_nodes" {
  description = "The number of observer nodes in the quorum cluster"
}

variable "vote_threshold" {
  description = "The number of votes needed to confirm a block. This should be more than half of the number of validator nodes."
}
