terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.1"
    }
  }
}

module "ec2" {
  source        = "../aws-ec2"
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ssh_key_name  = var.ssh_key_name
  ssh_key_file  = var.ssh_key_file
  instance_type = var.instance_type
  instance_name = "jump-box"
  ami_id        = data.aws_ami.ubuntu_latest.id
}
