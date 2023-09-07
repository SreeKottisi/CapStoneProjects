#Create a new VPC in AWS
resource "aws_vpc" "capstone1-vpc" {
  cidr_block = var.capstone1-vpc-cidr
  tags = {
    Name = "capstone1-vpc"
  }
}

#Creating 4Subnets, 2Private, 2public
/*The public subnet will have a public IP address assigned to each instance that is launched in it, while 
the private subnet will not. This allows you to control which instances are accessible from the 
internet and which are not.*/

#2Public Subnets
resource "aws_subnet" "capstone1-public-subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.capstone1-vpc.id
  cidr_block              = var.capstone1-public-subnet-cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-capstone1-public-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}
#2Private Subnets
resource "aws_subnet" "capstone1-private-subnet" {
  count             = 2
  vpc_id            = aws_vpc.capstone1-vpc.id
  cidr_block        = var.capstone1-private-subnet-cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-capstone1-private-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}


/*Route table for public subnets, this ensures that all instances launched in 
public subnet will have access to the internet*/
resource "aws_route_table" "capstone1-public-route-table" {
  vpc_id = aws_vpc.capstone1-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstone1-internet-gateway.id
  }
  tags = {
    Name = "${var.environment}-capstone1-public-route-table"
  }
}

#AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}