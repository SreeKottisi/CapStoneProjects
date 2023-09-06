#2. Gateway for Private Subnet
# We will be creating our EC2 instances in the private subnet, allowing only the requests from the load balancer to reach the instances.
# Elastic IP for NAT gateway
resource "aws_eip" "capstone1-ngw-eip" {
  depends_on = [aws_internet_gateway.capstone1-igw]
  domain     = "vpc"
  tags = {
    Name = "capstone1-ngw-eip"
  }
}

# NAT gateway for private subnets 
# (for the private subnet to access internet - eg. ec2 instances downloading softwares from internet)
resource "aws_nat_gateway" "capstone1-ngw-priv-subnet" {
  allocation_id = aws_eip.capstone1-ngw-eip.id
  subnet_id     = aws_subnet.capstone1-pub-1.id # nat should be in public subnet

  # [aws_subnet.capstone1-pub-1.id, aws_subnet.capstone1-pub-2.id, aws_subnet.capstone1-pub-3.id]

  tags = {
    Name = "capstone1-ngw NAT for private subnet"
  }

  depends_on = [aws_internet_gateway.capstone1-igw]
}

# route table - connecting to NAT
resource "aws_route_table" "capstone1-ngw-priv-RT" {
  vpc_id = aws_vpc.capstone1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.capstone1-ngw-priv-subnet.id
  }
}

# associate the route table with private subnet
resource "aws_route_table_association" "capstone1-ngw-priv-rta1" {
  subnet_id      = aws_subnet.capstone1-priv-1.id
  route_table_id = aws_route_table.capstone1-ngw-priv-RT.id
}

# associate the route table with private subnet
resource "aws_route_table_association" "capstone1-ngw-priv-rta2" {
  subnet_id      = aws_subnet.capstone1-priv-2.id
  route_table_id = aws_route_table.capstone1-ngw-priv-RT.id
}

# associate the route table with private subnet
resource "aws_route_table_association" "capstone1-ngw-priv-rta3" {
  subnet_id      = aws_subnet.capstone1-priv-3.id
  route_table_id = aws_route_table.capstone1-ngw-priv-RT.id
}
