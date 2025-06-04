resource "aws_s3_bucket" "tf_state" {
  bucket = "dev-tfstatefile-2025"
  tags = {
    Name = "Terraform State Bucket"
  }
}

# Key Pair
resource "aws_key_pair" "gitlab_runner_key" {
  key_name   = "gitlab-runner-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Security Group
resource "aws_security_group" "gitlab_runner_sg" {
  name        = "gitlab-runner-sg"
  description = "Allow GitLab Runner traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.150.108.17/32"] # Replace with your public ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "GitLab Runner SG"
  }
}

# IAM Role
resource "aws_iam_role" "gitlab_runner_role" {
  name = "gitlab-runner-role"

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

# IAM Policy
resource "aws_iam_policy" "gitlab_runner_policy" {
  name        = "gitlab-runner-policy"
  description = "Allow EC2 and S3 access for GitLab Runner"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeVpcs",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        Resource = "*"
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
resource "aws_iam_role_policy_attachment" "attach_gitlab_policy" {
  role       = aws_iam_role.gitlab_runner_role.name
  policy_arn = aws_iam_policy.gitlab_runner_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "gitlab_runner_instance_profile" {
  name = "gitlab-runner-instance-profile"
  role = aws_iam_role.gitlab_runner_role.name
}

# EC2 Instance
resource "aws_instance" "gitlab_runner" {
  ami                  = "ami-0f9de6e2d2f067fca" # Ubuntu 22.04
  instance_type        = var.instance_type
  key_name             = aws_key_pair.gitlab_runner_key.key_name
  security_groups      = [aws_security_group.gitlab_runner_sg.name]
  iam_instance_profile = aws_iam_instance_profile.gitlab_runner_instance_profile.name
  user_data            = file("userdata.sh")

  tags = {
    Name = "GitLab Runner"
  }

  depends_on = [aws_iam_instance_profile.gitlab_runner_instance_profile]

  provisioner "local-exec" {
    command = "echo ${self.id} > instance_id.txt"
  }

}
