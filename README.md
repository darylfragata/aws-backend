# GitHub Self-Hosted Runner on AWS with Terraform

This Terraform project deploys an EC2 instance as a self-hosted GitHub Actions runner. The GitHub runner token is securely stored in AWS SSM Parameter Store and fetched automatically by the instance during startup.

---

## Background

I created this project as part of my homelab to sharpen my **DevOps skills**. Since my company provides access to **A Cloud Guru's playground**, I decided to leverage it for my learning. However, the playground has a 5-hour limit, and all infrastructure is deleted once the session expires.

To overcome this limitation and avoid repeatedly setting up a GitHub runner for my homelab, I built this Terraform solution. It allows me to:

* Use a **self-hosted GitHub Actions runner** on AWS
* Store Terraform state files in an S3 bucket for other repositories
* Practice advanced workflows without worrying about the playground expiration

This approach helps me effectively utilize my A Cloud Guru access while maintaining a consistent learning environment for DevOps.

This project is executed entirely on my **local machine**, which communicates with the AWS infrastructure

---

## What It Creates

* **S3 Bucket** for Terraform state storage
* **SSH Key Pair** for EC2 access
* **Security Group** allowing SSH (port 22)
* **IAM Role** for EC2 with access to SSM Parameter Store and S3
* **SSM Parameter** storing the encrypted GitHub runner token
* **EC2 Instance** running Ubuntu 22.04, automatically installing and starting the GitHub runner via userdata

---

## Usage

1. **Update your runner token** in the Terraform file (`aws_ssm_parameter.github_runner_token`).
2. Adjust the instance type or SSH key path if needed.
3. Run the following commands **on your local machine** to deploy the infrastructure or execute `./initialsetup.sh` script to run all the commands below.

    ```bash
    terraform init  
    terraform plan  
    terraform apply  
    ```

4. After deployment, Terraform outputs:

   * `aws_s3_bucket_name` – your S3 bucket name
   * `aws_instance_pub_ip` – public IP of your runner EC2 instance

Sample output:

![alt text](/aws-backend/image/image.png)

5. SSH into the EC2 instance (using your SSH key) if you want to check logs or runner status. The runner is installed and started automatically.

---

## Userdata Script Highlights

* Updates system packages
* Installs dependencies: unzip, curl, python3-pip, git, jq
* Installs AWS CLI v2 and Terraform
* Retrieves GitHub runner token securely from SSM Parameter Store
* Downloads and configures GitHub Actions runner as user `ubuntu`
* Starts the GitHub Actions runner

Logs are saved at `/var/log/userdata.log` for troubleshooting.

---

## Security Notes

* The security group currently allows SSH from anywhere (`0.0.0.0/0`). Consider restricting it to trusted IPs only.
* The GitHub token is securely stored encrypted in SSM Parameter Store and not hard-coded on the instance.
* The instance role has limited permissions for security best practices.

---