#Create a new VPC in AWS
resource "aws_vpc" "capstone1-vpc" {
  cidr_block = var.capstone1-vpc-cidr
  tags = {
    Name = "capstone1-vpc"
  }
}

#AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}