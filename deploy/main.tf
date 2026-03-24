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

resource "aws_subnet" "basic-infra" {
  vpc_id            = aws_vpc.basic-infra.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "basic-infra"
  }
}
resource "aws_route_table" "public-subnet" {
  vpc_id = aws_vpc.basic-infra.id

  tags = {
    Name = "basic-infra"
  }
}
resource "aws_route_table_association" "public-subnet" {
  subnet_id      = aws_subnet.basic-infra.id
  route_table_id = aws_route_table.public-subnet.id
}   
resource "aws_route" "public-subnet" {
  route_table_id         = aws_route_table.public-subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.basic-infra.id
}