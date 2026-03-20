terraform {
  backend "s3" {
    bucket = "basic-infra-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "basic-infra" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "basic-infra"
  }
}

resource "aws_internet_gateway" "basic-infra" {
  vpc_id = aws_vpc.basic-infra.id

  tags = {
    Name = "basic-infra"
  }
}
