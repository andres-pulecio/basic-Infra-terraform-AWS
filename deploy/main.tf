terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "basic-infra-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

# ==================== VPC ====================

resource "aws_vpc" "basic-infra" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "basic-infra-vpc"
  }
}

resource "aws_internet_gateway" "basic-infra" {
  vpc_id = aws_vpc.basic-infra.id

  tags = {
    Name = "basic-infra-igw"
  }
}

# ==================== PUBLIC SUBNET ====================

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.basic-infra.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "basic-infra-public-subnet"
  }
}

resource "aws_route_table" "public-subnet" {
  vpc_id = aws_vpc.basic-infra.id

  tags = {
    Name = "basic-infra-public-rt"
  }
}

resource "aws_route_table_association" "public-subnet" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-subnet.id
}

resource "aws_route" "public-subnet" {
  route_table_id         = aws_route_table.public-subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.basic-infra.id
}

# ==================== NAT GATEWAY ====================

resource "aws_eip" "nat-gateway" {
  domain = "vpc"

  tags = {
    Name = "basic-infra-nat-eip"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-gateway.id
  subnet_id     = aws_subnet.public-subnet.id

  depends_on = [aws_internet_gateway.basic-infra]

  tags = {
    Name = "basic-infra-nat-gw"
  }
}

# ==================== PRIVATE SUBNET ====================

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.basic-infra.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "basic-infra-private-subnet"
  }
}

resource "aws_route_table" "private-subnet" {
  vpc_id = aws_vpc.basic-infra.id

  tags = {
    Name = "basic-infra-private-rt"
  }
}

resource "aws_route_table_association" "private-subnet" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-subnet.id
}

resource "aws_route" "private-subnet" {
  route_table_id         = aws_route_table.private-subnet.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
}