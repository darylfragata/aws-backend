output "aws_s3_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket

}

output "aws_instance_pub_ip" {
  value = aws_instance.github_runner.public_ip
}