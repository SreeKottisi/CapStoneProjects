# Create an Internet Gateway
resource "aws_internet_gateway" "jenkins-igw" {
  vpc_id = aws_vpc.jenkins_vpc.id
  tags = {
    Name = "jenkins-igw"
  }
}

resource "aws_route_table" "jenkins-igw-pub-RT" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins-igw.id
  }

  tags = {
    Name = "jenkins-pub-RT"
  }
}

resource "aws_route_table_association" "jenkins-igw-pub-1-a" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.jenkins-igw-pub-RT.id
}

resource "aws_route_table_association" "capstone1-igw-pub-2-a" {
  subnet_id      = aws_subnet.jenkins_subnet2.id
  route_table_id = aws_route_table.jenkins-igw-pub-RT.id
}
#resource "aws_route_table_association" "jenkins-igw-pub-3-a" {
#  subnet_id      = aws_subnet.jenkins-pub-3.id
#  route_table_id = aws_route_table.jenkins-igw-pub-RT.id
#}