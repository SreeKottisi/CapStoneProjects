# Security Group Resources
resource "aws_security_group" "capstone1-alb-security-group" {
  name        = "${var.environment}-capstone1-alb-security-group"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.capstone1-vpc.id
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-capstone1-alb-security-group"
  }
}
resource "aws_security_group" "capstone1-asg-security-group" {
  name        = "${var.environment}-capstone1-asg-security-group"
  description = "ASG Security Group"
  vpc_id      = aws_vpc.capstone1-vpc.id
  ingress {
    description     = "HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.capstone1-alb-security-group.id]
  }
  # Allow incoming SSH (port 22) traffic from your IP or specific CIDR block
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-capstone1-asg-security-group"
  }
}
