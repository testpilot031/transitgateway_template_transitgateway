variable "instances" {
  default = [
    { id = "hoge01", vpc_id = "hoge01",subnet_id = "hoge01_pri01", tags_Name = "hoge01" },
    { id = "hoge02", vpc_id = "hoge02", subnet_id = "hoge02_pri01",tags_Name = "hoge02" },
    { id = "hoge03", vpc_id = "hoge03", subnet_id = "hoge03_pri01",tags_Name = "hoge03" }
  ]
}


# ====================
#
# AMI
#
# ====================
# 最新版のAmazonLinux2のAMI情報
data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ====================
#
# EC2 Instance
#
# ====================
resource "aws_instance" "hoge" {
  for_each          = { for instance in var.instances : instance.id => instance }
  ami                    = data.aws_ami.example.image_id
  vpc_security_group_ids = [aws_security_group.hoge["${each.value.vpc_id}"].id]
  subnet_id              = aws_subnet.hoge["${each.value.subnet_id}"].id
  key_name               = aws_key_pair.example.id
  instance_type          = "t2.micro"
  user_data = <<EOF
    #!/bin/bash
    yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  EOF
  tags = {
    Name = "${each.value.id}"
  }
}
# ====================
#
# Elastic IP
#
# ====================
#resource "aws_eip" "example" {
#  instance = aws_instance.example.id
#  vpc      = true
#}
