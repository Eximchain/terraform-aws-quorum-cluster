# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "cert_tool_kms_key_id" {
  description = "The KMS Key ID that the cert tool encrypted the private key with. Will be output by the cert-tool module."
}

variable "cert_tool_server_cert_arn" {
  description = "The ARN of the IAM server certificate created for the Vault Load Balancer. Will be output by the cert-tool module."
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

variable "force_destroy_s3_buckets" {
  description = "Whether or not to force destroy s3 buckets. Set to true for an easily destroyed test environment. DO NOT set to true for a production environment."
  default     = false
}

variable "s3_bucket_suffix" {
  description = "A suffix to add to the end of deterministic s3 bucket names."
  default     = ""
}

variable "generate_metrics" {
  description = "Whether or not to generate CloudWatch metrics from the cluster. Set to false to disable for cost savings."
  default     = true
}

variable "create_alarms" {
  description = "Whether or not to create CloudWatch alarms. They will not function if generate_metrics is false."
  default     = false
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
  description = "Whether or not to give bootnodes elastic IPs, maintaining one static IP forever. Disabled by default because clusters with more than 5 nodes in one region using elastic IPs will require personally requesting more EIPs from AWS. WARNING: UNTESTED SINCE MOVING BOOTNODES INTO QUORUM VPC. MAY BE REMOVED IN A FUTURE UPDATE."
  default     = false
}

variable "use_elastic_observer_ips" {
  description = "Whether or not to give observers elastic IPs, maintaining one static IP forever. Disabled by default because clusters with more than 5 nodes in one region using elastic IPs will require personally requesting more EIPs from AWS."
  default     = false
}

variable "use_efs" {
  description = "Whether or not to use an EFS file system to store the chain data in this cluster. Will always be disabled in eu-west-2, ap-south-1, ca-central-1, and sa-east-1."
  default     = false
}

variable "exim_verbosity" {
  description = "The verbosity level of the exim process as an integer from 1 to 5. 0=silent, 1=error, 2=warn, 3=info, 4=debug, 5=detail."
  default = "2"
}

variable "ssh_ips" {
  description = "List of IP addresses allowed to SSH nodes in this network. If empty, will allow SSH from anywhere."
  default     = []
}

variable "other_validator_connection_ips" {
  description = "List of IP addresses outside the network that validators are allowed to directly connect to."
  default     = []
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

variable "quorum_amis" {
  description = "Mapping from AMI ID to use for quorum nodes. Defaults to getting the most recently built version from Eximchain"
  default     = {}
}

variable "bootnode_amis" {
  description = "Mapping from AMI ID to use for quorum nodes. Defaults to getting the most recently built version from Eximchain"
  default     = {}
}

variable "vault_consul_ami" {
  description = "AMI ID to use for vault and consul servers. Defaults to getting the most recently built version from Eximchain"
  default     = ""
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

variable "maker_max_peers" {
  description = "The number of peers each maker node will accept."
  default     = 25
}

variable "validator_max_peers" {
  description = "The number of peers each validator node will accept."
  default     = 25
}

variable "observer_max_peers" {
  description = "The number of peers each observer node will accept."
  default     = 25
}

variable "internal_dns_root_domain" {
  description = "The base domain for the hosted zone"
  default     = "exim"
}

variable "internal_dns_sub_domain_vault" {
  description = "The sub domain for the vault LB"
  default     = "vault"
}

variable "cert_tool_ca_public_key" {
  description = "The CA Public Key. If not provided, will default to loading from file."
  default     = ""
}

variable "cert_tool_public_key" {
  description = "The TLS Public Key. If not provided, will default to loading from file."
  default     = ""
}

variable "cert_tool_private_key_base64" {
  description = "The TLS Private Key. If not provided, will default to loading from file. Must be KMS encrypted in base64 format."
  default     = ""
}

variable "cert_tool_ca_public_key_file_path" {
  description = "The path where the cert-tool wrote the CA public key file. Path should be relative to the quorum vault module."
  default     = "certs/ca.crt.pem"
}

variable "cert_tool_public_key_file_path" {
  description = "The path where the cert-tool wrote the public key file. Path should be relative to the quorum vault module."
  default     = "certs/vault.crt.pem"
}

variable "cert_tool_private_key_file_path" {
  description = "The path where the cert-tool wrote the private key file. Path should be relative to the quorum vault module."
  default     = "certs/vault.key.pem"
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

variable "pre_baked_vault_enterprise_license" {
  description = "Set to true if using a vault enterprise binary with the license key pre-baked in."
  default     = false
}

variable "okta_base_url" {
  description = "The base URL to configure Okta access to vault with."
  default     = "okta.com"
}

variable "okta_org_name" {
  description = "The organization name to configure Okta access to use. Leave empty to skip configuring Okta vault access."
  default     = ""
}

variable "okta_api_token" {
  description = "The API token to configure Okta access to use. Leave empty to skip configuring Okta vault access."
  default     = ""
}

variable "okta_access_group" {
  description = "The Okta group that should be granted access to the vault. Leave empty to skip configuring Okta vault access."
  default     = ""
}

variable "az_override" {
  description = "A Mapping from AWS region to a comma-separated string of AZs to use for that region. Overrides dynamically reading available AZs."
  default     = {}
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


variable "backup_lambda_binary" {
  description = "Name of BackupLambda binary"
  default = "BackupLambda"
}

variable "backup_lambda_ssh_private_key" {
  description = <<DESCRIPTION
SSH private key to be used for authentication.
DESCRIPTION
  default     = ""
}

variable "backup_lambda_ssh_private_key_path" {
  description = <<DESCRIPTION
Path to the SSH private key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform
DESCRIPTION
  default     = ""
}

# output prefix of encrypted SSH key, region will be appended to the filename
variable "enc_ssh_path" {
  description = "Full path to the encrypted SSH key to be generated, region will be appended to the filename"
  default = "enc-ssh"
}

# key on S3 bucket
variable "enc_ssh_key" {
  description = "The key to access the encrypted SSH key on the S3 bucket"
  default = "enc-ssh"
}

variable "backup_interval" {
  description = <<DESCRIPTION
Schedule expression for backup event, see https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html for examples.
cron(45 08 ? * WED *) will trigger every WED at 8 45 am GMT
cron(05 13 ? * MON *) will trigger every MON at 1 05 pm GMT
rate(3 mins) will trigger every 3 minutes
rate(7 hours) will trigger every 7 hours
DESCRIPTION
  default     = "rate(4 days)"
}

variable "backup_enabled" {
  description = <<DESCRIPTION
Enable backup of chain data.
DESCRIPTION
  default = "false"
}

variable "backup_lambda_ssh_user" {
  description = "SSH user for connecting to nodes."
  default = "ubuntu"
}

variable "backup_lambda_ssh_pass" {
  description = "SSH password to use for connecting to nodes. If not specified, uses the backup_lambda_ssh_private_key or backup_lambda_ssh_private_key_path."
  default = ""
}
