resource "aws_instance" "capstone1-jenkins-server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.capstone1-key.key_name
  vpc_security_group_ids = [aws_security_group.capstone1-jenkins-security-group.id]
  tags = {
    Name = "capstone1-jenkins-server"
  }
  user_data = base64encode("${var.ec2_user_data}")
}

#This user data variable indicates that the script configures Apache on a server.
variable "ec2_user_data" {
  description = "variable indicates that the script configures Jenkins on a server"
  type        = string
  default     = <<EOF
#!/bin/bash
  sudo useradd -m -s /bin/bash ec2-user
  sudo usermod -aG sudo ec2-user
  sudo yum update -y
  sudo amazon-linux-extras install java-openjdk11 -y

# install jenkins server
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  sudo yum install jenkins -y
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
EOF
}

# Security Group Resources
resource "aws_security_group" "capstone1-jenkins-security-group" {
  name        = "${var.environment}-capstone1-jenkins-security-group"
  description = "jenkins Security Group"
  vpc_id      = "vpc-04c6e8ec56543d218"
  ingress {
    description = "HTTP from Internet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.environment}-capstone1-jenkins-security-group"
  }
}

resource "aws_s3_bucket" "capstone1-artifact-s3-bkt" {
    bucket = "capstone1-artifact-s3-bkt"
}
