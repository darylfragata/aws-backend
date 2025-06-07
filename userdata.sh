#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Redirect logs
exec > /var/log/userdata.log 2>&1

# Update the system
sudo apt update -y

# Install essential dependencies
sudo apt install -y unzip curl python3-pip git jq

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

# Verify installations
terraform --version
git --version
python3 --version

# Retrieve GitHub Runner Token from SSM Parameter Store
RUNNER_TOKEN=$(aws ssm get-parameter \
    --name "/github/runner/token" \
    --with-decryption \
    --region us-east-1 \
    --query "Parameter.Value" \
    --output text)

if [ -z "$RUNNER_TOKEN" ]; then
    echo "Failed to retrieve GitHub Runner token. Exiting."
    exit 1
fi

# Install GitHub Runner
sudo -u ubuntu mkdir -p /home/ubuntu/actions-runner
sudo -u ubuntu curl -o /home/ubuntu/actions-runner/actions-runner-linux-x64-2.325.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-linux-x64-2.325.0.tar.gz
sudo -u ubuntu tar xzf /home/ubuntu/actions-runner/actions-runner-linux-x64-2.325.0.tar.gz -C /home/ubuntu/actions-runner

#Pass the token explicitly in the sudo environment when running config.sh:
#By default, sudo -u ubuntu clears environment variables, so it’s safer to explicitly pass the token in the environment:
sudo -u ubuntu env RUNNER_TOKEN="$RUNNER_TOKEN" /home/ubuntu/actions-runner/config.sh --url https://github.com/darylfragata/aws-devops-homelab --token "$RUNNER_TOKEN" --name "aws-github-runner" --labels "aws-backend"
sudo -u ubuntu /home/ubuntu/actions-runner/run.sh

 