#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in server mode. Note that this script assumes it's running in an AMI
# built from the Packer template in examples/vault-consul-ami/vault-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

function configure_threatstack_agent_if_key_provided {
  if [ "${threatstack_deploy_key}" != "" ]
  then
    echo "{
      \"deploy-key\": \"${threatstack_deploy_key}\",
      \"ruleset\": \"Base Rule Set\",
      \"agent_type\": \"i\"
}" | sudo tee /opt/threatstack/config.json
  fi
}

function run_threatstack_agent_if_configured {
  if [ -e /opt/threatstack/config.json ]
  then
    echo "Threatstack agent configuration found. Starting Agent."
    sudo cloudsight setup --config="/opt/threatstack/config.json"
  else
    echo "No Threatstack agent configuration found."
  fi
}

function setup_foxpass_if_specified {
  if [ "${foxpass_base_dn}" != "" ] && [ "${foxpass_bind_user}" != "" ] && [ "${foxpass_bind_pw}" != "" ] && [ "${foxpass_api_key}" != "" ]
  then
    echo "Foxpass variables specified. Running foxpass_setup.py."
    sudo python3 /opt/foxpass_setup.py --base-dn ${foxpass_base_dn} --bind-user ${foxpass_bind_user} --bind-pw ${foxpass_bind_pw} --api-key ${foxpass_api_key}
  else
    echo "Foxpass variables not specified."
  fi
}

# Start Supervisor
supervisord -c /etc/supervisor/supervisord.conf

setup_foxpass_if_specified

configure_threatstack_agent_if_key_provided
run_threatstack_agent_if_configured

# These variables are passed in via Terraform template interpolation
/opt/consul/bin/run-consul --server --cluster-tag-key "${consul_cluster_tag_key}" --cluster-tag-value "${consul_cluster_tag_value}"
