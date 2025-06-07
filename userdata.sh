#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Update the system
sudo apt update -y

# Install essential dependencies
sudo apt install -y unzip curl python3-pip git

#Install jq
apt-get update && apt-get install -y jq

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify AWS CLI v2 installation
aws --version

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update -y
sudo apt install -y terraform

# Verify Terraform installation
terraform --version

# Verify Git installation
git --version

# Verify Python installation
python3 --version

#######################
# # Install GitHub Runner

mkdir actions-runner && cd actions-runner

curl -o actions-runner-linux-x64-2.325.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-linux-x64-2.325.0.tar.gz

tar xzf ./actions-runner-linux-x64-2.325.0.tar.gz

./config.sh --url https://github.com/darylfragata/aws-devops-homelab --token $RUNNER_TOKEN

# Start the runner
./run.sh

# #######################
# # Install GitLab Runner
# curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
# chmod +x /usr/local/bin/gitlab-runner

# # Create runner user
# useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# # Install and start runner
# gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
# gitlab-runner start

# # Register the runner
# gitlab-runner register --non-interactive \
#   --url "https://gitlab.com/" \
#   --registration-token "glrt-yz8RZxpD3jp-pGtF6Kn8" \
#   --executor "shell" \
#   --description "ec2_gitlab_runner"

# # Fix for .bash_logout issue that causes job to fail during "prepare environment"
# BASH_LOGOUT_FILE="/home/gitlab-runner/.bash_logout"

# # Create if not exists
# touch "$BASH_LOGOUT_FILE"

# # Comment out the entire clear_console block
# if grep -q "clear_console" "$BASH_LOGOUT_FILE"; then
#   # Backup original
#   cp "$BASH_LOGOUT_FILE" "${BASH_LOGOUT_FILE}.bak"

#   # Replace the clear_console block with a safe commented version
#   awk '
#     BEGIN { skip = 0 }
#     /if \[ "\$SHLVL" = 1 \]; then/ { print "#if [ \"$SHLVL\" = 1 ]; then"; skip = 1; next }
#     /\[ -x \/usr\/bin\/clear_console \] && \/usr\/bin\/clear_console -q/ && skip == 1 { print "#    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q"; next }
#     /fi/ && skip == 1 { print "#fi"; skip = 0; next }
#     { print }
#   ' "${BASH_LOGOUT_FILE}.bak" > "$BASH_LOGOUT_FILE"
# fi

# # Set correct ownership
# chown gitlab-runner:gitlab-runner "$BASH_LOGOUT_FILE"

