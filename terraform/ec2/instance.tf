 # Define o provedor AWS onde serão criados os recursos
provider "aws" {
  region = var.aws_region
  shared_credentials_file = "/var/jenkins_home/workspace/.aws/creds"
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.project}"
  }
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Tier = "Public"
  }
}

data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.all.ids
  id = "${each.value}"
}

resource "random_shuffle" "random_subnet" {
  input        = [for s in data.aws_subnet.public : s.id]
  result_count = 1
}

resource "aws_elb" "web" {
  name = "mps-lava-rapido"

  subnets         = data.aws_subnet_ids.all.ids
  security_groups = ["${aws_security_group.allow-ssh.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 6
  }

  # The instances are registered automatically
  instances = aws_instance.web.*.id
}

resource "aws_instance" "web" {
  instance_type = var.instance_type
  ami           = var.aws_amis
  count = 2

  subnet_id              = "${random_shuffle.random_subnet.result[0]}"
  vpc_security_group_ids = ["${aws_security_group.allow-ssh.id}"]
  key_name               = "${var.KEY_NAME}"

  provisioner "local-exec" {
      command = "echo ${self.public_dns} >> inventory"    
  }
    provisioner "local-exec" {
      command = "sleep 90"    
  }

  provisioner "local-exec" {
      command = "ansible-playbook -i inventory --private-key ${var.PATH_TO_KEY} main.yml -u ${var.INSTANCE_USERNAME} -e'limit=${self.public_dns}' "
  }

  connection {
    user        = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${var.PATH_TO_KEY}")}"
    host = self.public_dns
  }

  tags = {
    Name = "${format("nginx-%02d", count.index + 1)}"
  }
}