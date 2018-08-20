# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "cert_owner" {
  description = "The OS user to be made the owner of the local copy of the vault certificates. Should usually be set to the user operating the tool."
}

variable "vote_threshold" {
  description = "The number of votes needed to confirm a block. This should be more than half of the number of validator nodes."
}

variable "min_block_time" {
  description = "The minimum number of seconds a block maker should wait between proposing blocks."
}

variable "max_block_time" {
  description = "The maximum number of seconds a block maker should wait between proposing blocks."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "network_id" {
  description = <<DESCRIPTION
Ethereum network ID, also used in naming some resources for uniqueness.
Must be unique amongst networks in the same AWS account and launched with this tool.
Ideally is globally unique amongst ethereum and quorum networks.
DESCRIPTION
  default = 64813
}

variable "gas_limit" {
  description = "The limit on gas that can be used in a single block"
  default     = 804247552
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
  default     = "~/.ssh/quorum.pub"
}

variable "public_key" {
  description = <<DESCRIPTION
SSH public key to be used for authentication.
Will override public_key_path if set.
DESCRIPTION
  default     = ""
}

variable "private_key" {
  description = <<DESCRIPTION
SSH private key to be used for authentication.
Will use the agent if none is provided.
DESCRIPTION
  default     = ""
}

variable "primary_region" {
  description = "The AWS region that single-region resources like the vault and consul clusters will be placed in."
  default     = "us-east-1"
}

variable "vault_port" {
  description = "The port that vault will be accessible on."
  default     = 8200
}

variable "vault_consul_ami" {
  description = "AMI ID to use for vault and consul servers. Defaults to getting the most recently built version from Eximchain"
  default     = ""
}

variable "quorum_amis" {
  description = "Mapping from AMI ID to use for quorum nodes. Defaults to getting the most recently built version from Eximchain"
  default     = {}
}

variable "bootnode_amis" {
  description = "Mapping from AMI ID to use for quorum nodes. Defaults to getting the most recently built version from Eximchain"
  default     = {}
}

variable "force_destroy_s3_buckets" {
  description = "Whether or not to force destroy s3 buckets. Set to true for an easily destroyed test environment. DO NOT set to true for a production environment."
  default     = false
}

variable "generate_metrics" {
  description = "Whether or not to generate CloudWatch metrics from the cluster. Set to false to disable for cost savings."
  default     = true
}

variable "use_dedicated_bootnodes" {
  description = "Whether or not to use dedicated instances for bootnodes."
  default     = false
}

variable "use_dedicated_makers" {
  description = "Whether or not to use dedicated instances for maker nodes."
  default     = false
}

variable "use_dedicated_validators" {
  description = "Whether or not to use dedicated instances for validator nodes."
  default     = false
}

variable "use_dedicated_observers" {
  description = "Whether or not to use dedicated instances for observer nodes."
  default     = false
}

variable "use_dedicated_vault_servers" {
  description = "Whether or not to use dedicated instances for vault servers."
  default     = false
}

variable "use_dedicated_consul_servers" {
  description = "Whether or not to use dedicated instances for consul servers."
  default     = false
}

variable "use_elastic_bootnode_ips" {
  description = "Whether or not to give bootnodes elastic IPs, maintaining one static IP forever. Disabled by default because clusters with more than 5 bootnodes in one region will require personally requesting more EIPs from AWS."
  default     = false
}

variable "ssh_ips" {
  description = "List of IP addresses allowed to SSH nodes in this network. If empty, will allow SSH from anywhere."
  default     = []
}

variable "cert_org_name" {
  description = "The organization to associate with the vault certificates."
  default     = "Example Co."
}

variable "bootnode_instance_type" {
  description = "The EC2 instance type to use for bootnodes"
  default = "t2.small"
}

variable "quorum_maker_instance_type" {
  description = "The EC2 instance type to use for maker nodes"
  default     = "t2.small"
}

variable "quorum_validator_instance_type" {
  description = "The EC2 instance type to use for validator nodes"
  default     = "t2.small"
}

variable "quorum_observer_instance_type" {
  description = "The EC2 instance type to use for observer nodes"
  default     = "t2.small"
}

variable "vault_cluster_size" {
  description = "The number of instances to use in the vault cluster"
  default     = 3
}

variable "vault_instance_type" {
  description = "The EC2 instance type to use for vault nodes"
  default     = "t2.micro"
}

variable "consul_cluster_size" {
  description = "The number of instances to use in the consul cluster"
  default     = 3
}

variable "consul_instance_type" {
  description = "The EC2 instance type to use for consul nodes"
  default     = "t2.micro"
}

variable "quorum_vpc_base_cidr" {
  description = "Base CIDR range to assign quorum VPCs from."
  default     = "10.0.0.0/16"
}

variable "bootnode_vpc_base_cidr" {
  description = "Base CIDR range to assign bootnode VPCs from."
  default     = "172.16.0.0/16"
}

variable "node_volume_size" {
  description = "The size of the EBS volume for a quorum node in GB"
  default     = 20
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

variable "vault_enterprise_license_key" {
  description = "The license key to use for vault enterprise. Leave empty if using free version."
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
