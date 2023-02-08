terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }

  #required_version = "~> 3.0"
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
}

module "security_group" {
<<<<<<< HEAD
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  my_ip  = var.my_IP
=======
  source                = "./modules/security_group"
  vpc_id                = module.vpc.vpc_id
  my_ip                 = var.my_IP
>>>>>>> 004e31973e9de6905df9131bd1557628d43e4e8a
  jenkins_ingress_rules = var.jenkins_ingress_rules
}

module "ec2_instance" {
  source         = "./modules/compute"
  security_group = module.security_group.sg_id
  public_subnet  = module.vpc.public_subnet_id
}
