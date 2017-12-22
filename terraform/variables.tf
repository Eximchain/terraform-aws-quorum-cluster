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

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
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
