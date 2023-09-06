resource "aws_vpc" "capstone1" {
  cidr_block           = "13.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "capstone1-vpc"
  }
}

resource "aws_subnet" "capstone1-pub-1" {
  vpc_id                  = aws_vpc.capstone1.id
  cidr_block              = "13.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE1
  tags = {
    Name = "capstone1-pub-1"
  }
}

resource "aws_subnet" "capstone1-pub-2" {
  vpc_id                  = aws_vpc.capstone1.id
  cidr_block              = "13.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE2
  tags = {
    Name = "capstone1-pub-2"
  }
}

resource "aws_subnet" "capstone1-pub-3" {
  vpc_id                  = aws_vpc.capstone1.id
  cidr_block              = "13.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ZONE3
  tags = {
    Name = "capstone1-pub-3"
  }
}

resource "aws_subnet" "capstone1-priv-1" {
  vpc_id                  = aws_vpc.capstone1.id
  cidr_block              = "13.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = var.ZONE1
  tags = {
    Name = "capstone1-priv-1"
  }
}

resource "aws_subnet" "capstone1-priv-2" {
  vpc_id                  = aws_vpc.capstone1.id
  cidr_block              = "13.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = var.ZONE2
  tags = {
    Name = "capstone1-priv-2"
  }
}

resource "aws_subnet" "capstone1-priv-3" {
  vpc_id                  = aws_vpc.capstone1.id
  cidr_block              = "13.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = var.ZONE3
  tags = {
    Name = "capstone1-priv-3"
  }
}
