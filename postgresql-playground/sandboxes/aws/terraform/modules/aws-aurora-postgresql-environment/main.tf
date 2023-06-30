terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.1"
    }
  }
}

module "vpc" {
  source = "../aws-vpc"
}

module "jump_box" {
  source        = "../aws-ec2-ubuntu"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets_ids[0]
  instance_name = "jump-box"
  #ssh_key_file  = "~/.ssh/id_rsa.pub"
}

module "aurora_postgresql" {
  source                     = "../aws-aurora-postgresql"
  vpc_id                     = module.vpc.vpc_id
  allowed_availability_zones = module.vpc.availability_zones
  subnets_ids                = module.vpc.private_subnets_ids
}
