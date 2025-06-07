#!/bin/bash
cd ..
set -e  # Exit on error

terraform init
terraform apply -auto-approve

echo -e "\nCOMPLETED\n"
rm -rf instance_id*
