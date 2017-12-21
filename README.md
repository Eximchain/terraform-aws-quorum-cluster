# Warning
This software launches and uses real AWS resources. It is not a demo or test. By using this software, you will incur the costs of any resources it uses in your AWS account.

Please be aware of the variables when using packer and terraform, as certain settings have the potential to incur large costs.

# Work In Progress
This repository is a work in progress. A more complete version of this README and code is coming soon.

# Basic Usage

## Prerequisites

* You must have AWS credentials at the default location (typically ~/.aws/credentials)
* You must have the following programs installed on the machine you will be using to launch the network:
    * Python 2
    * Hashicorp Packer
    * Hashicorp Terraform

## Generate TLS Certificates for vault

Use the cert tool to generate TLS certificates

```sh
$ cd cert-tool
$ terraform apply
# Enter "yes" and wait for cert generation
$ cd ..
```

## Build AMIs to launch the instances with

Use packer to build the AMIs needed to launch instances

```sh
$ cd packer
$ packer build vault-consul.json
# Enter "yes" and wait for build
$ packer build quorum.json
# Enter "yes" and wait for build
$ cd ..
```

Then copy the AMIs to into terraform variables

```sh
$ python copy-packer-artifacts-to-terraform.py
```

If you would like to back up the previous AMI variables in case something goes wrong with the new one, you can use this invocation instead

```sh
$ BACKUP=<File path to back up to>
$ python copy-packer-artifacts-to-terraform.py --tfvars-backup-file $BACKUP
```

## Launch Network with Terraform

Copy the examples.tfvars file

```sh
$ cd terraform
$ cp examples.tfvars terraform.tfvars
```

Check terraform.tfvars and change any values you would like to change. Note that the values given in examples.tfvars is NOT completely AWS free tier eligible. We do not recommend using t2.micro instances, as they were unable to compile solidity during testing.

Apply the terraform configuration

```sh
$ terraform apply
# Enter "yes" and wait for infrastructure creation
```

Note the IPs in the output or retain the terminal output. You will need them to finish setting up the cluster.

## Launch and configure vault

Pick a vault server IP to ssh into:

```sh
$ IP=<vault server IP>
$ ssh ubuntu@$IP
```

Initialize the vault. Choose the number of key shards and the unseal threshold based on your use case. For a simple test cluster, choose 1 for both. If you are using enterprise vault, you may configure the vault with another unseal mechanism as well.

```sh
$ KEY_SHARES=<Number of key shards>
$ KEY_THRESHOLD=<Number of keys needed to unseal the vault>
$ vault init -key-shares=$KEY_SHARES -key-threshold=$KEY_THRESHOLD 
```

Unseal the vault and initialize it with permissions for the quorum nodes. Once setup-vault.sh is complete, the quorum nodes will be able to finish their boot-up procedure.

```sh
$ UNSEAL_KEY=<Unseal key output by vault init command>
$ ROOT_TOKEN=<Root token output by vault init command>
$ vault unseal $UNSEAL_KEY
$ /opt/vault/bin/setup-vault.sh $ROOT_TOKEN
```

If any of these commands fail, wait a short time and try again. If waiting doesn't fix the issue, you may need to destroy and recreate the infrastructure.
