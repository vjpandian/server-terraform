#!/bin/bash

# set TLS env vars
echo "export TF_VAR_nomad_server_cert=$(cat /etc/nomad/ssl/cert.pem)" >> ~/.bashrc
echo "export TF_VAR_nomad_server_key=$(cat /etc/nomad/ssl/key.pem)" >> ~/.bashrc
echo "export TF_VAR_nomad_tls_ca=$(cat /etc/nomad/ssl/ca.pem)" >> ~/.bashrc
source ~/.bashrc

cd nomad-aws
terraform init
terraform plan

# sleeping to keep the job container up long enough for debugging
sleep 1h