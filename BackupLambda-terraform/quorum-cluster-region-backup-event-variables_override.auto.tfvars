# This is to be placed in quorum-cluster-region
# Due to a bug in Terraform, changes in this file canont be detected.
# So, changes should be made in quorum-cluster-region-backup-event-variables_override.tf instead

# Must be absolute path to the BackupLamda binary!
BackupLambda_source_file = "/Users/xxxx/Documents/GitHub/AWSBackupLambda/BackupLambda"

# Must not be absolute path!!! The zip filename of the BackupLambda
# eg "BackupLambda.zip"
BackupLambda_output_path = "BackupLambda.zip"

# The full path to the private key to use to SSH into the Quorum nodes
# eg "/Users/xxxx/.ssh/somekey"
private_key_path = "/Users/xxxx/.ssh/quorum"

# The full path to the public key
# eg "/Users/xxxx/.ssh/somekey.pub"
public_key_path = "/Users/xxxx/.ssh/quorum.pub"

# The location of the temporarily encrypted SSH file, must be an absolute path
# eg "/tmp/encrypted-ssh"
enc_ssh_path = "/tmp/encrypted-ssh"

# Changing this value would require updating the Go source code as well.
# The key on the S3 bucket to read the encrypted SSH certificate.
enc_ssh_key = "enc_ssh"


# refer to https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
# for expression to use
# rate(3 hours) - every 3 hours
# cron(5 8 * * SUN) - runs at 8:05 on every SUN
backup_interval = "cron(5 8 * * SUN *)"

# Used for development
integrating = "false"
debug = "false"
