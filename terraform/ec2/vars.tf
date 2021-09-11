variable "aws_region" {
  default     = "us-east-1"
}
variable "project" {
  default = "home-lab"
}
variable "aws_amis" {
  default =  "ami-087c17d1fe0178315" ## Amazon Linux
}
variable "instance_type" {
  default     = "t2.micro"
}
variable "PATH_TO_KEY" {
    default = "/var/jenkins_home/workspace/.ssh/chave-fiap.pem"  
}
variable "KEY_NAME" {
    default = "chave-fiap"  
}
variable "INSTANCE_USERNAME" {
    default = "ec2-user"  
}
