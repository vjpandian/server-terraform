#!/bin/bash


cd nomad-aws
terraform init
terraform plan

# sleeping to keep the job container up long enough for debugging
sleep 1h