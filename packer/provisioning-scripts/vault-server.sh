#!/bin/bash
set -eu -o pipefail

SCRIPT_VER="v0.0.8"
VAULT_VER="0.9.0"

git clone --branch $SCRIPT_VER https://github.com/hashicorp/terraform-aws-vault.git
terraform-aws-vault/modules/install-vault/install-vault --version $VAULT_VER
