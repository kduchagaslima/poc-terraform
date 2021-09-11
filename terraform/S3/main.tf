 # Define o provedor AWS onde serão criados os recursos
provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/var/jenkins_home/workspace/.aws/creds"
}
# Cria um bucket S3
resource "aws_s3_bucket" "b" {
  bucket = "my-poc-terraform-state"
  acl    = "private"

  tags = {
    Name        = "Terraform State"
    Environment = "PoC"
  }
}