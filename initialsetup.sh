#!/bin/bash

set -e  # Exit on error

terraform init
terraform apply -auto-approve
# echo "update IAM role, then apply changes"
# python update_main_tf_with_instance_id.py
# echo -e "\n\n"
# terraform apply -auto-approve
echo -e "\nCOMPLETED\n"
rm -rf instance_id*
