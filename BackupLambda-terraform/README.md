This documents the Terraform configuration required to implement and deploy the Backup Lambda that calls the python backup script on the quorum clusters.

There are a total of 11 Terraform files implementing the changes.
The files are named with the prefix being the directory where the file is supposed to be placed.

* The first character of the filename up to the last dash (-) indicates the directory where the file itself is supposed to be placed.
* If a file does not have a dash in its filename, it is supposed to be placed in the root directory of the Terraform project.

As an example, for quorum-cluster-main_override.tf, this place is to be placed into the quorum-cluster directory.

