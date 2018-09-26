# The variables below are tied to various usage in the main Terraform configuration as well as in the Lambda function written in Go.
# Do not change the bucket names without also changing the main Terraform configuration and compiling the modified Lambda function.
bucket_key = "enc-ssh"           # name of encrypted SSH key output on S3 bucket
bucket_prefix = "eximchain105-"  # prefix of S3 bucket
enc_ssh = "~/enc-ssh"            # name of encrypted SSH key output on local disk

key_name = "public_key105"       # name of the public key pair
key_pair_prefix = "awsxxx"
key_path    = "~/.ssh/quorum.pub"  # name of the public key corresponding to private_ssh
private_ssh = "~/.ssh/quorum"      # location of private SSH key to be encrypted

# lambda sources
lambda_output_path = "UpgradeLambda.zip"
lambda_source_file = "./UpgradeLambda"

raw_upgrade_cmd = "raw-upgrade-cmd" # the key containing the upgrade cmd
ssh_username = "ssh_username"       # SSH username variable
ssh_usernamevalue = "ubuntu"        # value of the SSH username variable
version_prefix = "105"

upgrade_bucket_prefix = "upg"
upgrade_key = "upgrade.sh"         # this needs to be an executable name, same as the upgrade_file

# physical location of the upgrade file, which will be uploaded to the upgrade_bucket
upgrade_file = "./upgrade.sh" 

# various upgrade commands
upgrade_cmd = "upgrade_cmd"
upgrade_cmd_value = "upgrade.sh"      # this is expected to be a script
upgrade_location = "upgrade_location" # used by BackupLambda, do not change unless the BackupLambda is changed too
upgrade_location_value = "/home/ubuntu"      # where to place upgrade script and upgrade.zip
upgrade_zip_key = "upgrade.zip"
upgrade_zip_file = "upgrade.zip"
upgradesh_key = "upgrade.sh"

# Used for informing that notifications are completed
notify_prefix = "eximchainnotify-"

# VPC to use
vpc_cidr_block = "10.0.0.0/16"