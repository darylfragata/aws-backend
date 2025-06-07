resource "aws_s3_bucket" "tf_state" {
  bucket = "dev-tfstatefile-2025"
  tags = {
    Name = "Terraform State Bucket"
  }
}

# Key Pair
resource "aws_key_pair" "github_runner_key" {
  key_name   = "github-runner-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Security Group
resource "aws_security_group" "github_runner_sg" {
  name        = "github-runner-sg"
  description = "Allow github Runner traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your github IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "GitHub Runner SG"
  }
}

# IAM Role
resource "aws_iam_role" "github_runner_role" {
  name = "github-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Parameter Store Access and S3 Access
resource "aws_iam_policy" "github_policy_access" {
  name        = "github-runner-policy"
  description = "Allow EC2 and S3 access for github Runner"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = "arn:aws:ssm:us-east-1:*:parameter/github/runner/token"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::dev-tfstatefile-backend",
          "arn:aws:s3:::dev-tfstatefile-backend/*"
        ]
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_parameter_policy" {
  role       = aws_iam_role.github_runner_role.name
  policy_arn = aws_iam_policy.github_policy_access.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "github_runner_instance_profile" {
  name = "github-runner-instance-profile"
  role = aws_iam_role.github_runner_role.name
}

# Parameter Store for GitHub Runner Token
resource "aws_ssm_parameter" "github_runner_token" {
  name        = "/github/runner/token"
  description = "GitHub Runner token for authentication"
  type        = "SecureString" # Use SecureString for encrypted storage
  value       = "THNKTH1SISTOKENSZCX" # Replace with your token
  tags = {
    Environment = "HomeLab"
  }
}

# EC2 Instance
resource "aws_instance" "github_runner" {
  ami                  = "ami-0f9de6e2d2f067fca" # Ubuntu 22.04
  instance_type        = var.instance_type
  key_name             = aws_key_pair.github_runner_key.key_name
  security_groups      = [aws_security_group.github_runner_sg.name]
  iam_instance_profile = aws_iam_instance_profile.github_runner_instance_profile.name
  user_data            = file("userdata.sh")

  tags = {
    Name = "GitHub Runner"
  }

  depends_on = [aws_iam_instance_profile.github_runner_instance_profile]
}
