terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = "<-------paste your aws access key------->"
  secret_key = "<-------paste your aws secret key------->"
  region     = "ap-southeast-1"
}

# VPC
data "aws_availability_zones" "available" {}
module "test_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test-vpc"
  cidr = "192.168.0.0/16"

  azs             = data.aws_availability_zones.available.names
  public_subnets  = ["192.168.50.0/24"]

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true

}

# Security Group
module "test_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "test-sg"
  description = "rule for ec2"
  vpc_id      = module.test_vpc.vpc_id

  ingress_with_cidr_blocks      = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks       = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_ipv6_cidr_blocks  = [
    {
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      ipv6_cidr_blocks  = "::/0"
    }
  ]
}

# EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "<-------paste your public key------->"
}
module "test_ec2" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "data-sci"
  instance_count         = 1

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  monitoring             = false
  vpc_security_group_ids = [module.test_sg.security_group_id]
  subnet_id              = module.test_vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}