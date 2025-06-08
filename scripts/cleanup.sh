#!/bin/bash

cd ..
terraform destroy -auto-approve
echo -e "\nDestroyed Terraform resources\n"
set -e  # Exit on error
echo -e "\nRemoving residue...\n"
rm -rf .terraform*
echo -e "Removed .terraform files"
rm -rf scripts/terraform.tfstate
rm -rf terraform.tfstate*
echo -e "Removed .tfstate file"
rm -rf .hcl
echo -e "Removed .hcl file"
echo -e "\nCOMPLETED\n"

