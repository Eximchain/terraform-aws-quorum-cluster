# This file must be placed in the quorum-cluster directory

variable "private_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
  default     = "/Users/chuacw/.ssh/quorum"
}