Table of Contents
=================

   * [Warning](#warning)
   * [Work In Progress](#work-in-progress)
   * [Quick Start Guide](#quick-start-guide)
      * [Prerequisites](#prerequisites)
      * [Supported Regions](#supported-regions)
   * [Generate SSH key for EC2 instances](#generate-ssh-key-for-ec2-instances)
      * [Build AMIs to launch the instances with](#build-amis-to-launch-the-instances-with)
         * [Faster Test Builds](#faster-test-builds)
      * [Generate Certificates](#generate-certificates)
         * [Delete Terraform State](#delete-terraform-state)
      * [Launch Network with Terraform](#launch-network-with-terraform)
      * [Launch and configure vault](#launch-and-configure-vault)
         * [Unseal additional vault servers](#unseal-additional-vault-servers)
      * [Access the Quorum Node](#access-the-quorum-node)
         * [Check processes have started](#check-processes-have-started)
         * [Attach the Exim Console](#attach-the-exim-console)
         * [Run Private Transaction Test](#run-private-transaction-test)
            * [Deploy the private contract](#deploy-the-private-contract)
         * [Destroy the Network](#destroy-the-network)
   * [Using as a Terraform Module](#using-as-a-terraform-module)
   * [Architecture](#architecture)
      * [Terraform Modules](#terraform-modules)
         * [quorum-cluster](#quorum-cluster)
         * [quorum-vault](#quorum-vault)
         * [quorum-cluster-region](#quorum-cluster-region)
         * [cert-tool](#cert-tool)
         * [consul-security-group-rule](#consul-security-group-rule)
         * [internal-dns](#internal-dns)
         * [quorum-vpc-peering](#quorum-vpc-peering)
      * [Diagrams](#diagrams)
         * [Full network at a high level](#full-network-at-a-high-level)
         * [VPC Peering Connections](#vpc-peering-connections)
         * [Quorum Cluster Region](#quorum-cluster-region-1)
         * [Network Topology](#network-topology)

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

You may skip this step. If you do, your AMI will be the most recent one built by the official Eximchain AWS Account. We try to keep this as recent as possible but currently no guarantees are made.

If you want the script to copy the vault_consul AMI, ensure it is only built into the region the vault cluster will be in.

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

These builds can be run in parallel as well

Then copy the AMIs to into terraform variables

```sh
$ python copy-packer-artifacts-to-terraform.py
```

If you would like to back up the previous AMI variables in case something goes wrong with the new one, you can use this invocation instead

```sh
$ BACKUP=<File path to back up to>
$ python copy-packer-artifacts-to-terraform.py --tfvars-backup-file $BACKUP
```

### Faster Test Builds

If you want to quickly build an AMI to test changes, you can use an `insecure-test-build`.  This skips over several lengthy software upgrades that require building a new software version from source. The AMIs produced will have additional security vulnerabilities and are not suitable for use in production systems.

To use this feature, simply run the builds from the `packer/insecure-test-builds` directory as follows:

```sh
$ cd packer/insecure-test-builds
$ packer build vault-consul.json
# Wait for build
$ packer build bootnode.json
# Wait for build
$ packer build quorum.json
# Wait for build
$ cd ../..
```

Then continue by copying the AMIs to into terraform variables as usual:

```sh
$ python copy-packer-artifacts-to-terraform.py
```

## Generate Certificates

Certificates need to be generated separately, before launching the network. This allows us to delete the state for the cert-tool, which contains the certificate private key, for improved security in a production network.

Change to the cert-tool directory

```sh
$ cd terraform/cert-tool
```

Copy the example.tfvars file

```sh
$ cp example.tfvars terraform.tfvars
```

Then open `terraform.tfvars` in a text editor and change anything you'd like to change.

Finally, `init` and `apply` the configuration

```sh
$ terraform init
$ terraform apply
# Respond 'yes' at the prompt
```

Take note of the output. You will need to input some values into the terraform variables for the next configuration.

If this is an ephemeral test network, you do not need to recreate the certificates every time you replace the network. You can run it once and reuse the certificates each time.

### Delete Terraform State

If this is a production network, or otherwise one in which you are concerned about security, you will need to delete the terraform state, since it contains the plaintext private key, even if you enabled KMS encryption.

```sh
$ rm terraform.tfstate*
```

Be aware that an `aws_iam_server_certificate` and an `aws_kms_key` are both created by this configuration, and if the state is deleted they will no longer be managed by Terraform. Be sure you have saved the output from the configuration so that it can be imported by other configurations or cleaned up manually.

## Launch Network with Terraform

Change to the terraform directory, if you aren't already there from the above step

```sh
$ cd terraform
```

Copy the example.tfvars file

```sh
$ cp example.tfvars terraform.tfvars
```

Check terraform.tfvars and change any values you would like to change:
- **Certificate Details:** You will need to fill in the values for `cert_tool_kms_key_id` and `cert_tool_server_cert_arn`. Replace `FIXME` with the values from the output of the `cert-tool`.
- **SSH Location:** Our default example file is built for OS X, which puts your home directory and its `.ssh` folder (aka `~/.ssh`) at `/Users/$USER/.ssh`.  If your SSH keyfile is not located within that directory, you will need to update the `public_key_path`.
- **Network ID:** We have a default network value.  If there is already a network running with this ID on your AWS account, you need to change the network ID or there will be a conflict.  
- **Not Free:** The values given in `example.tfvars` are NOT completely AWS free tier eligible, as they include t2.small and t2.medium instances. We do not recommend using t2.micro instances, as they were unable to compile solidity during testing.
- **Bootnode Elastic IPs:** Elastic IP addresses for bootnodes are disabled by default because AWS requires you to manually request more EIPs if you configure a network with more than 5 bootnodes per region.  Enabling this feature (`use_elastic_bootnode_ips`) will maintain one static IP address for each bootnode for the lifetime of the network, keeping you from having to update stored enode addresses when bootnodes fail over.

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
$ vault operator init -key-shares=$KEY_SHARES -key-threshold=$KEY_THRESHOLD
```

Unseal the vault and initialize it with permissions for the quorum nodes. Once setup-vault.sh is complete, the quorum nodes will be able to finish their boot-up procedure. Note that this example is for a single key initialization, and if the key is sharded with a threshold greater than one, multiple users will need to run the unseal command with their shards.

```sh
$ UNSEAL_KEY=<Unseal key output by vault operator init command>
$ vault operator unseal $UNSEAL_KEY
$ ROOT_TOKEN=<Root token output by vault operator init command>
$ /opt/vault/bin/setup-vault.sh $ROOT_TOKEN
```

If any of these commands fail, wait a short time and try again. If waiting doesn't fix the issue, you may need to destroy and recreate the infrastructure.

### Unseal additional vault servers

You can proceed with initial setup with only one unsealed server, but if all unsealed servers crash, the vault will become inaccessable even though the severs will be replaced. If you have multiple vault servers, you may unseal all of them now and if the server serving requests crashes, the other servers will be on standby to take over.

SSH each vault server and for enough unseal keys to reach the threshold run:
```sh
$ UNSEAL_KEY=<Unseal key output by vault operator init command>
$ vault operator unseal $UNSEAL_KEY
```

## Access the Quorum Node

SSH any quorum node and wait for the exim and constellation processes to start. There is an intentional delay to allow bootnodes to start first.

### Check processes have started

One way to check is to inspect the log folder. If exim and constellation have started, we expect to find logs for `constellation` and `quorum`, not just `init-quorum`.

```sh
$ ls /opt/quorum/log
```

Another way is to check the supervisor config folder. if exim and constellation have started, we expect to find files `quorum-supervisor.conf` and `constellation-supervisor.conf`.

```sh
$ ls /etc/supervisor/conf.d
```

Finally, you can check for the running processes themselves.  Expect to find a running process other than your grep for each of these.

```sh
$ ps -aux | grep constellation-node
$ ps -aux | grep exim
```

### Attach the Exim Console

Once the processes are all running, you can attach your console to the exim JavaScript console

```sh
$ exim attach
```

You should be able to see your other nodes as peers

```javascript
> admin.peers
```

### Run Private Transaction Test

The nodes come equipped to run a simple private transaction test (sourced from the official quorum-examples repository) between two nodes.

#### Deploy the private contract

SSH into the sending node (e.g. node 0) and run the following to deploy the private contract

If you are using Foxpass SSH key management, first authenticate to vault with AWS. You will also need to use `sudo` to run the test

```sh
$ vault auth -method=aws
$ RECIPIENT_PUB_KEY=$(vault read -field=constellation_pub_key quorum/addresses/us-east-1/1)
$ sudo /opt/quorum/bin/private-transaction-test-sender.sh $RECIPIENT_PUB_KEY
```

Otherwise, you should be authenticated already and `sudo` is not necessary

```sh
# This assumes that the entire network is running in us-east-1
# This assumes there are at least two nodes in us-east-1 and the recipient is the node with index 1
# (the second maker node, or the first validator node if there is only one maker in us-east-1)
# If you would like to choose a different recipient, modify the path beginning with "quorum/addresses"
$ RECIPIENT_PUB_KEY=$(vault read -field=constellation_pub_key quorum/addresses/us-east-1/1)
$ /opt/quorum/bin/private-transaction-test-sender.sh $RECIPIENT_PUB_KEY
```

The exim console will be attached. Wait for output indicating the contract was mined, which should appear as follows:

```javascript
> Contract mined! Address: 0x74d977a43deaac2281b6f3d489719f6d2e4aae74
[object Object]
```

Take note of the address, then in another terminal, SSH into the recipient node and run the following to load the private contract:

```sh
$ CONTRACT_ADDR=<Address of the mined private contract>
$ /opt/quorum/bin/private-transaction-test-recipient.sh $CONTRACT_ADDR
```

The exim console will be attached and the private contract will be loaded. Both the sender and recipient should be able to get the following result from querying the contract:

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
  quorum_maker_instance_type = "t2.medium"
  quorum_validator_instance_type = "t2.medium"
  quorum_observer_instance_type = "t2.medium"
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

# Architecture

## Terraform Modules

The following modules can be found in the `terraform/modules` directory. The root quorum configuration in `terraform` is simply a wrapper for the `quorum-cluster` module.

These modules contain the core functionality to run the infrastructure for a quorum cluster:

### quorum-cluster

The top-level module, suitable for being used directly by another terraform configuration. The `quorum-cluster` module consists primarily of a single `quorum-vault` in the primary region, and 14 `quorum-cluster-region` modules which contain the bulk of the infrastructure (since most of it is regionalized). Additionally, it contains some resources to create a cloudwatch dashboard and alarms in the default region.

### quorum-vault

The `quorum-vault` module provides a durable and secure [Hashicorp Vault](https://www.vaultproject.io/) cluster for use by the whole cluster. This module is used only in the primary region. It maintains a vault cluster, a consul cluster to support it, and an Elastic Load Balancer through which the vault cluster can be accessed. This module is not intended to be used outside a `quorum-cluster` module.

### quorum-cluster-region

The `quorum-cluster-region` module contains all infrastructure which exists independently in all regions, which is most of it. Note that no infrastructure is created in a region with all node counts set to `0`.

The following major components are included in a `quorum-cluster-region`:

* For the whole region
  * A key pair to SSH the instances in the cluster
  * An S3 bucket for constellation payloads
  * An S3 bucket for chain backups
  * An IAM policy allowing access to AWS dependencies
* For Bootnodes
  * A VPC
  * One subnet per AZ
  * User data scripts
  * One Autoscaling group per bootnode
  * One IAM role per bootnode
  * One security group and rules for it allowing:
    * SSH access which may be limited to specified IPs
    * Access to the constellation port from anywhere
    * Access to the quorum port from anywhere
    * Access to the bootnode discovery port from anywhere
    * Local access to the RPC port
* For Quorum Nodes
  * A VPC
  * Three subnets per AZ, one for each network role
  * User data scripts
  * One Autoscaling group per node
  * One IAM role per node
  * One security group and rules for it allowing:
    * SSH access which may be limited to specified IPs
    * Access to the constellation port from anywhere
    * Access to the quorum port from specified other roles (see [Network Topology](#network-topology) for more details)
    * Access to the bootnode discovery port from anywhere
    * Local access to the RPC port
    * Local access to the supervisor RPC port
  * Network ACL rules preventing makers and supervisors from communicating on their exim ports (see [Network Topology](#network-topology) for more details)

The following modules contain supporting functionality

### cert-tool

The `cert-tool` module is used in the Quick Start Guide to generate certificates for vault. This needs to be done outside the main module to avoid having unencrypted private keys persisted in the terraform state.

### consul-security-group-rule

This module is originally sourced from a Hashicorp module. It provides security group rules for the consul cluster used in the `quorum-vault` module.

### internal-dns

This module provides a shared private DNS system for the whole cluster by creating a Route53 private hosted zone and associating it with all VPCs in the cluster.

Currently this provides a fixed well-known DNS for the vault load balancer so that the certificates can be generated before the load balancer is created.

### quorum-vpc-peering

This creates peering connections between the vault VPC and each quorum VPC, as well as between each pair of quorum VPCs. The result is that all VPCs except the bootnode VPCs are connected to each other via peering connections, and can communicate over them.

This has desirable properties. One is that the vault load balancer can be kept internal, reducing the attack surface for the vault server. Another is that exim processes establish connections using their private IPs, which allows us to set cross-region security group rules based on private IP CIDR ranges. This is important in enforcing the [Network Topology](#network-topology).

## Diagrams

Note that for simplicity, these diagrams depict a three region network. The primary region is `us-east-1` and the network also has nodes in `us-west-2` and `eu-west-1`. Additional regions used that may be used in your network have the same architecture as the non-primary regions depicted.

### Full network at a high level

![Full Cluster Architecture](images/full-cluster-overview.png "Full Cluster Architecture")

This diagram shows the breakdown of the architecture into regions and VPCs, including components that are exclusive to the primary region. The components common to all regions will be expanded upon in another diagram. Note that connections between components are omitted to avoid clutter.

### VPC Peering Connections

![VPC Peering Connections](images/vpc-peering-connections.png "VPC Peering Connections")

This diagram shows the VPC Peering Connections between VPCs. The Vault VPC and the Quorum Node VPCs are all directly connected to each other. Bootnode VPCs are not connected to any other VPCs.  Also pictured is the Internal DNS system, consisting of a single Route53 private hosted zone associated with all VPCs including bootnode VPCs.

### Quorum Cluster Region

![Quorum Cluster Region](images/quorum-cluster-region.png "Quorum Cluster Region")

This diagram shows a more detailed view of a non-primary region. The primary region has additional components as detailed in the full network diagram. This infrastructure is managed by the `quorum-cluster-region` module and exists in every region with nodes in them. For simplicity, connections between components are omitted and only two Availability Zones and two nodes per AZ are shown.

### Network Topology

![Network Topology](images/network-topology.png "Network Topology")

The network topology is enforced via the AWS control plane and attempts to obtain a fully connected network ensuring the best possible connectivity between makers and validators. Towards this end, all non-maker connections to the network go through observer nodes. To allow connections to your network, users should use the observer nodes as bootnodes.

Incoming network connections through other nodes are prevented by security group rules. Since connections can be opened in either direction, Makers and Observers are specifically kept from connecting to each other by ACL rules at the subnet level.

Through clever choice of `max_peers` and the number of nodes in your network, it is possible to ensure that your initial network is strongly connected.
