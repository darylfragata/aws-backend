#!/bin/bash

cd ..
set -e  # Exit on error
echo -e "\nRemoving residue...\n"
rm -rf .terraform*
echo -e "Removed .terraform files"
rm -rf terraform.tfstate
echo -e "Removed .tfstate file"
rm -rf .hcl
echo -e "Removed .hcl file"
echo -e "\nCOMPLETED\n"

