# Define your AWS provider configuration
provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

# Create a VPC
resource "aws_vpc" "jenkins_vpc" {
  cidr_block = "10.0.0.0/16" # Modify as per your requirements
}

# Create public and private subnets
resource "aws_subnet" "jenkins_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.0.1.${count.index}/24"                                       # Modify as per your requirements
  availability_zone       = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index) # Modify AZs as needed
  map_public_ip_on_launch = true
}

resource "aws_subnet" "jenkins_private_subnet" {
  count                   = 1
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.0.2.${count.index}/24"                                       # Modify as per your requirements
  availability_zone       = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index) # Modify AZs as needed
  map_public_ip_on_launch = false
}

# Create a security group for Jenkins master
resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins-master-sg"
  description = "Security group for Jenkins master"
  vpc_id      = aws_vpc.jenkins_vpc.id

  # Define ingress rules to allow traffic to Jenkins master
  ingress {
    from_port   = 8080 # Jenkins HTTP port
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow access from anywhere (adjust as needed)
  }

  # Add additional rules as needed for SSH or other services
}

# Create an EC2 instance for Jenkins master within an Auto Scaling Group
resource "aws_launch_configuration" "jenkins_master_launch_config" {
  name_prefix   = "jenkins-master-lc-"
  image_id      = "ami-xxxxxxxxxxxxxxxxx" # Jenkins-specific AMI ID
  instance_type = "t2.micro"              # Choose an appropriate instance type

  security_groups = [aws_security_group.jenkins_master_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Install Jenkins
              sudo yum update -y
              sudo amazon-linux-extras install java-openjdk11 -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              sudo yum install jenkins -y
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF
}

resource "aws_autoscaling_group" "jenkins_master_asg" {
  name_prefix               = "jenkins-master-asg-"
  launch_configuration      = aws_launch_configuration.jenkins_master_launch_config.name
  min_size                  = 1 # Minimum Jenkins master instances
  max_size                  = 3 # Maximum Jenkins master instances (updated to 3)
  desired_capacity          = 1 # Initial desired capacity
  vpc_zone_identifier       = aws_subnet.jenkins_public_subnet[*].id
  wait_for_capacity_timeout = "10m" # Adjust as needed
}

# Create a security group for Jenkins slaves
resource "aws_security_group" "jenkins_slave_sg" {
  name        = "jenkins-slave-sg"
  description = "Security group for Jenkins slaves"
  vpc_id      = aws_vpc.jenkins_vpc.id

  # Define ingress rules for Jenkins master to connect to slaves
  ingress {
    from_port       = 22 # SSH port for Jenkins master to connect
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_master_sg.id] # Allow only Jenkins master to connect
  }
}

# Create EC2 instances for Jenkins slaves
resource "aws_instance" "jenkins_slave" {
  count         = 2
  ami           = "ami-xxxxxxxxxxxxxxxxx" # Jenkins-specific AMI ID
  instance_type = "t2.micro"              # Choose an appropriate instance type

  subnet_id = element(aws_subnet.jenkins_private_subnet[*].id, count.index)

  security_groups = [aws_security_group.jenkins_slave_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Add your slave setup commands here
              EOF
}

# Output the Jenkins master instance public IP
output "jenkins_master_ip" {
  value = aws_autoscaling_group.jenkins_master_asg.desired_capacity
}

# Output the Jenkins slave instance public IPs
output "jenkins_slave_ips" {
  value = aws_instance.jenkins_slave[*].public_ip
}