# This is to be placed in quorum-cluster-region

# this is the lambda binary
# eg "/Users/xxxx/BackupLambda"
variable "BackupLambda_source_file" {default="/Users/xxxx/Documents/GitHub/AWSBackupLambda/BackupLambda"}

# this is the lambda zip, must be a relative path
# eg "BackupLambda.zip"
variable "BackupLambda_output_path" {default="BackupLambda.zip"}

# This is the private key path
# eg "/Users/xxxx/.ssh/cert"
variable "private_key_path" {default="/Users/xxxx/.ssh/cert"}

# This is the public key path
# eg "/Users/xxxx/.ssh/cert.pub"
variable "public_key_path" {default="/Users/xxxx/.ssh/cert.pub"}

# output prefix of encrypted SSH key, region will be appended to the filename
variable "enc_ssh_path" {default="/tmp/encrypted-ssh"}

# key on S3 bucket
variable "enc_ssh_key" {default="enc_ssh"}
variable "integrating" {default="false"}

# If singular, it's 1 hour, 1 minute, 1 week, 1 day, etc.
# If plural, it's 2 hours, 2 minutes, 2 weeks, 7 days, etc.
variable "backup_interval" {
    default="rate(4 hours)"
}

// this creates an AWS test instance for the Lambda to SSH into
// with the KMS encrypted key, which it will decrypt within memory
variable "debug" {default=""}

