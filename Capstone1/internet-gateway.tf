# Create an Internet Gateway
resource "aws_internet_gateway" "capstone1-igw" {
  vpc_id = aws_vpc.capstone1.id
  tags = {
    Name = "capstone1-igw"
  }
}

resource "aws_route_table" "capstone1-igw-pub-RT" {
  vpc_id = aws_vpc.capstone1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstone1-igw.id
  }

  tags = {
    Name = "capstone1-pub-RT"
  }
}

resource "aws_route_table_association" "capstone1-igw-pub-1-a" {
  subnet_id      = aws_subnet.capstone1-pub-1.id
  route_table_id = aws_route_table.capstone1-igw-pub-RT.id
}

resource "aws_route_table_association" "capstone1-igw-pub-2-a" {
  subnet_id      = aws_subnet.capstone1-pub-2.id
  route_table_id = aws_route_table.capstone1-igw-pub-RT.id
}
resource "aws_route_table_association" "capstone1-igw-pub-3-a" {
  subnet_id      = aws_subnet.capstone1-pub-3.id
  route_table_id = aws_route_table.capstone1-igw-pub-RT.id
}