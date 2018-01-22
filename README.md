Table of Contents
=================

   * [Warning](#warning)
   * [Work In Progress](#work-in-progress)
   * [Quick Start Guide](#quick-start-guide)
      * [Prerequisites](#prerequisites)
      * [Supported Regions](#supported-regions)
   * [Generate SSH key for EC2 instances](#generate-ssh-key-for-ec2-instances)
      * [Build AMIs to launch the instances with](#build-amis-to-launch-the-instances-with)
      * [Launch Network with Terraform](#launch-network-with-terraform)
      * [Launch and configure vault](#launch-and-configure-vault)
         * [Unseal additional vault servers](#unseal-additional-vault-servers)
      * [Access the Quorum Node](#access-the-quorum-node)
         * [Check processes have started](#check-processes-have-started)
         * [Attach the Geth Console](#attach-the-geth-console)
         * [Run Private Transaction Test](#run-private-transaction-test)
            * [Deploy the private contract](#deploy-the-private-contract)
         * [Destroy the Network](#destroy-the-network)
   * [Using as a Terraform Module](#using-as-a-terraform-module)
   * [Roadmap](#roadmap)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

# Warning
This software launches and uses real AWS resources. It is not a demo or test. By using this software, you will incur the costs of any resources it uses in your AWS account.

Please be aware of the variables when using packer and terraform, as certain settings have the potential to incur large costs.

# Work In Progress
This repository is a work in progress. A more complete version of this README and code is coming soon.

# Quick Start Guide

## Prerequisites

* You must have AWS credentials at the default location (typically `~/.aws/credentials`)
* You must have the following programs installed on the machine you will be using to launch the network:
    * Python 2.7
    * Hashicorp Packer
    * Hashicorp Terraform

## Supported Regions

The following AWS regions are supported for use with this tool. Attempting to use regions not on this list may result in unexpected behavior. Note that this list may change over time
in the event new regions are added to AWS infrastructure or incompatibilities with existing regions are added or discovered.

* us-east-1
* us-east-2
* us-west-1
* us-west-2
* eu-central-1
* eu-west-1
* eu-west-2
* eu-west-3
* ap-south-1
* ap-northeast-1
* ap-northeast-2
* ap-southeast-1
* ap-southeast-2
* ca-central-1
* sa-east-1

# Generate SSH key for EC2 instances

Generate an RSA key with ssh-keygen. This only needs to be done once. If you change the output file location you must change the key paths in the terraform variables file later.

```sh
$ ssh-keygen -t rsa -f ~/.ssh/quorum
# Enter a password if you wish
```

Add the key to your ssh agent. This must be done again if you restart your computer. If this is not done, it will cause problems provisioning the instances with terraform.

```sh
$ ssh-add ~/.ssh/quorum
# Enter your password if there is one
```

## Build AMIs to launch the instances with

Use packer to build the AMIs needed to launch instances

```sh
$ cd packer
$ packer build vault-consul.json
# Wait for build
$ packer build bootnode.json
# Wait for build
$ packer build quorum.json
# Wait for build
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

Copy the example.tfvars file

```sh
$ cd terraform
$ cp example.tfvars terraform.tfvars
```

Fill in your username as the `cert_owner`:

```sh
$ sed -i '' "s/FIXME_USER/$USER/" terraform.tfvars
```

Check terraform.tfvars and change any values you would like to change. Note that the values given in examples.tfvars is NOT completely AWS free tier eligible, as they include t2.small and t2.medium instances. We do not recommend using t2.micro instances, as they were unable to compile solidity during testing.

If it is your first time using this package, you will need to run `terraform init` before applying the configuration.

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

Unseal the vault and initialize it with permissions for the quorum nodes. Once setup-vault.sh is complete, the quorum nodes will be able to finish their boot-up procedure. Note that this example is for a single key initialization, and if the key is sharded with a threshold greater than one, multiple users will need to run the unseal command with their shards.

```sh
$ UNSEAL_KEY=<Unseal key output by vault init command>
$ vault unseal $UNSEAL_KEY
$ ROOT_TOKEN=<Root token output by vault init command>
$ /opt/vault/bin/setup-vault.sh $ROOT_TOKEN
```

If any of these commands fail, wait a short time and try again. If waiting doesn't fix the issue, you may need to destroy and recreate the infrastructure.

### Unseal additional vault servers

You can proceed with initial setup with only one unsealed server, but if all unsealed servers crash, the vault will become inaccessable even though the severs will be replaced. If you have multiple vault servers, you may unseal all of them now and if the server serving requests crashes, the other servers will be on standby to take over.

SSH each vault server and for enough unseal keys to reach the threshold run:
```sh
$ UNSEAL_KEY=<Unseal key output by vault init command>
$ vault unseal $UNSEAL_KEY
```

## Access the Quorum Node

SSH any quorum node and wait for the geth and constellation processes to start. There is an intentional delay to allow bootnodes to start first.

### Check processes have started

One way to check is to inspect the log folder. If geth and constellation have started, we expect to find logs for `constellation` and `quorum`, not just `init-quorum`.

```sh
$ ls /opt/quorum/log
```

Another way is to check the supervisor config folder. if geth and constellation have started, we expect to find files `quorum-supervisor.conf` and `constellation-supervisor.conf`.

```sh
$ ls /etc/supervisor/conf.d
```

Finally, you can check for the running processes themselves.  Expect to find a running process other than your grep for each of these.

```sh
$ ps -aux | grep constellation-node
$ ps -aux | grep geth
```

### Attach the Geth Console

Once the processes are all running, you can attach your console to the geth JavaScript console

```sh
$ geth attach
```

You should be able to see your other nodes as peers

```javascript
> admin.peers
```

### Run Private Transaction Test

The nodes come equipped to run a simple private transaction test (sourced from the official quorum-examples repository) between two nodes.

#### Deploy the private contract

SSH into the sending node (e.g. node 0) and run the following to deploy the private contract

```sh
# This assumes that the entire network is running in us-east-1
# This assumes there are at least two nodes in us-east-1 and the recipient is the node with index 1
# (the second maker node, or the first validator node if there is only one maker in us-east-1)
# If you would like to choose a different recipient, modify the path beginning with "quorum/addresses"
$ RECIPIENT_PUB_KEY=$(vault read -field=constellation_pub_key quorum/addresses/us-east-1/1)
$ /opt/quorum/bin/private-transaction-test-sender.sh $RECIPIENT_PUB_KEY
```

The geth console will be attached. Wait for output indicating the contract was mined, which should appear as follows:

```javascript
> Contract mined! Address: 0x74d977a43deaac2281b6f3d489719f6d2e4aae74
[object Object]
```

Take note of the address, then in another terminal, SSH into the recipient node and run the following to load the private contract:

```sh
$ CONTRACT_ADDR=<Address of the mined private contract>
$ /opt/quorum/bin/private-transaction-test-recipient.sh $CONTRACT_ADDR
```

The geth console will be attached and the private contract will be loaded. Both the sender and recipient should be able to get the following result from querying the contract:

```javascript
> simple.get()
42
```

To demonstrate privacy, you can run the recipient script on a third instance that is not the intended recipient:

```sh
$ CONTRACT_ADDR=<Address of the mined private contract>
$ /opt/quorum/bin/private-transaction-test-recipient.sh $CONTRACT_ADDR
```

The third instance should get the following result instead when querying the contract:

```javascript
> simple.get()
0
```

### Destroy the Network

If this is a test network and you are finished with it, you will likely want to destroy your network to avoid incurring extra AWS costs:

```sh
# From the terraform directory
$ terraform destroy
# Enter "yes" and wait for the network to be destroyed
```

If it finishes with a single error that looks like as follows, ignore it.  Rerunning `terraform destroy` will show that there are no changes to make.

```
Error: Error applying plan:

1 error(s) occurred:

* aws_s3_bucket.quorum_vault (destroy): 1 error(s) occurred:

* aws_s3_bucket.quorum_vault: Error deleting S3 Bucket: NoSuchBucket: The specified bucket does not exist
	status code: 404, request id: 8641A613A9B146ED, host id: TjS8J2QzS7xFgXdgtjzf6FR1Z2x9uqA5UZLHaMEWKg7I9JDRVtilo6u/XSN9+Qnkx+u5M83p4/w= "quorum-vault"

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
```

# Using as a Terraform Module

This repository maintains a terraform module, which you can add to your code by adding a `module` configuration and setting the `source` to the URL of the module:

```hcl
module "quorum_cluster" {
  # Use v0.0.1-alpha
  source = "github.com/Eximchain/terraform-aws-quorum-cluster//terraform/modules/quorum-cluster?ref=v0.0.1-alpha"

  # These values from example.tfvars
  public_key_path           = "~/.ssh/quorum.pub"
  private_key_path          = "~/.ssh/quorum"
  key_name                  = "quorum-cluster"
  aws_region                = "us-east-1"
  network_id                = 64813
  force_destroy_s3_buckets  = true
  quorum_azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vault_cluster_size        = 1
  vault_instance_type       = "t2.small"
  consul_cluster_size       = 1
  consul_instance_type      = "t2.small"
  bootnode_cluster_size     = 1
  bootnode_instance_type    = "t2.small"
  quorum_node_instance_type = "t2.medium"
  num_maker_nodes           = 1
  num_validator_nodes       = 1
  num_observer_nodes        = 1
  vote_threshold            = 1

  # Currently assuming these are filled in by variables
  quorum_amis   = "${var.quorum_amis}"
  vault_amis    = "${var.vault_amis}"
  bootnode_amis = "${var.bootnode_amis}"
}
```

# Roadmap

The master list of desired features for this tool. Feel free to contribute feature requests via pull requests editing this section. Items here may correspond with open issues.

- [x] Dedicated Boot Nodes for Geth and Constellation
- [x] Replaceable Boot Nodes
- [x] Auto-starting geth and constellation processes
- [x] Private transaction test case
- [x] Multi AZ Network
- [x] Isolate different AWS users in the same account
- [x] New Constellation Configuration Format
- [x] Terraform Module
- [ ] Multi Region Network
- [ ] Quorum Node health checking and replacement
- [ ] Full initial documentation
- [ ] Secure handling of TLS Certificate
- [ ] Anti-Fraglie Everything
- [ ] Fine-grained Permissions for Private Keys in Vault
- [ ] Tighten security parameters
- [ ] Network with External Participants
