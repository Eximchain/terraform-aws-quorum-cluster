# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "cert_owner" {
  description = "The OS user to be made the owner of the local copy of the vault certificates. Should usually be set to the user operating the tool."
}

variable "public_key" {
  description = "The public key that will be used to SSH the instances in this region."
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

variable "vault_consul_ami" {
  description = "AMI ID to use for vault and consul servers. Defaults to getting the most recently built version from Eximchain"
  default     = ""
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

variable "use_dedicated_vault_servers" {
  description = "Whether or not to use dedicated instances for vault servers."
  default     = false
}

variable "use_dedicated_consul_servers" {
  description = "Whether or not to use dedicated instances for consul servers."
  default     = false
}

variable "lb_ssl_policy" {
  description = "The SSL policy to use for the vault load balancer"
  default     = "ELBSecurityPolicy-2016-08"
}

variable "ssh_ips" {
  description = "List of IP addresses allowed to SSH nodes in this network. If empty, will allow SSH from anywhere."
  default     = []
}

variable "cert_org_name" {
  description = "The organization to associate with the vault certificates."
  default     = "Example Co."
}

variable "vault_enterprise_license_key" {
  description = "The license key to use for vault enterprise. Leave empty if using free version."
  default     = ""
}

variable "threatstack_deploy_key" {
  description = "Deploy key to use to activate threatstack agents, if using one"
  default     = ""
}

variable "foxpass_base_dn" {
  description = "The Base DN for your Foxpass account, if managing SSH keys with Foxpass"
  default     = ""
}

variable "foxpass_bind_user" {
  description = "The bind user name for your Foxpass account, if managing SSH keys with Foxpass"
  default     = ""
}

variable "foxpass_bind_pw" {
  description = "The bind user password for your Foxpass account, if managing SSH keys with Foxpass"
  default     = ""
}

variable "foxpass_api_key" {
  description = "The API key for your Foxpass account, if managing SSH keys with Foxpass"
  default     = ""
}

variable "bootnode_counts" {
  description = "A mapping from region to the number of bootnodes to launch in that region"
  type        = "map"
  default     = {
    # Virginia
    us-east-1      = 0
    # Ohio
    us-east-2      = 0
    # California
    us-west-1      = 0
    # Oregon
    us-west-2      = 0
    # Frankfurt
    eu-central-1   = 0
    # Ireland
    eu-west-1      = 0
    # London
    eu-west-2      = 0
    # Mumbai
    ap-south-1     = 0
    # Tokyo
    ap-northeast-1 = 0
    # Seoul
    ap-northeast-2 = 0
    # Singapore
    ap-southeast-1 = 0
    # Sydney
    ap-southeast-2 = 0
    # Canada
    ca-central-1   = 0
    # South America
    sa-east-1      = 0
  }
}

variable "maker_node_counts" {
  description = "A mapping from region to the number of maker nodes to launch in that region"
  type        = "map"
  default     = {
    # Virginia
    us-east-1      = 0
    # Ohio
    us-east-2      = 0
    # California
    us-west-1      = 0
    # Oregon
    us-west-2      = 0
    # Frankfurt
    eu-central-1   = 0
    # Ireland
    eu-west-1      = 0
    # London
    eu-west-2      = 0
    # Mumbai
    ap-south-1     = 0
    # Tokyo
    ap-northeast-1 = 0
    # Seoul
    ap-northeast-2 = 0
    # Singapore
    ap-southeast-1 = 0
    # Sydney
    ap-southeast-2 = 0
    # Canada
    ca-central-1   = 0
    # South America
    sa-east-1      = 0
  }
}

variable "validator_node_counts" {
  description = "A mapping from region to the number of validator nodes to launch in that region"
  type        = "map"
  default     = {
    # Virginia
    us-east-1      = 0
    # Ohio
    us-east-2      = 0
    # California
    us-west-1      = 0
    # Oregon
    us-west-2      = 0
    # Frankfurt
    eu-central-1   = 0
    # Ireland
    eu-west-1      = 0
    # London
    eu-west-2      = 0
    # Mumbai
    ap-south-1     = 0
    # Tokyo
    ap-northeast-1 = 0
    # Seoul
    ap-northeast-2 = 0
    # Singapore
    ap-southeast-1 = 0
    # Sydney
    ap-southeast-2 = 0
    # Canada
    ca-central-1   = 0
    # South America
    sa-east-1      = 0
  }
}

variable "observer_node_counts" {
  description = "A mapping from region to the number of observer nodes to launch in that region"
  type        = "map"
  default     = {
    # Virginia
    us-east-1      = 0
    # Ohio
    us-east-2      = 0
    # California
    us-west-1      = 0
    # Oregon
    us-west-2      = 0
    # Frankfurt
    eu-central-1   = 0
    # Ireland
    eu-west-1      = 0
    # London
    eu-west-2      = 0
    # Mumbai
    ap-south-1     = 0
    # Tokyo
    ap-northeast-1 = 0
    # Seoul
    ap-northeast-2 = 0
    # Singapore
    ap-southeast-1 = 0
    # Sydney
    ap-southeast-2 = 0
    # Canada
    ca-central-1   = 0
    # South America
    sa-east-1      = 0
  }
}
