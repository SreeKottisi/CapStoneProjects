# Create a VPC
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "170.0.0.0/16" # Modify the CIDR block as needed
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create a subnet within the VPC
resource "aws_subnet" "jenkins_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "170.0.1.0/24" # Modify the CIDR block for your subnet
  availability_zone       = "us-east-1a"   # Modify the availability zone as needed
  map_public_ip_on_launch = true
}

# Create a subnet within the VPC
resource "aws_subnet" "jenkins_subnet2" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "170.0.2.0/24" # Modify the CIDR block for your subnet
  availability_zone       = "us-east-1b"   # Modify the availability zone as needed
  map_public_ip_on_launch = true
}

# Reference the ELB's security group
resource "aws_security_group" "jenkins_lb_sg" {
  name        = "jenkins-lb-sg"
  description = "Security group for ELB"
  vpc_id      = aws_vpc.jenkins_vpc.id
  
  # Allow incoming HTTP (port 8080) traffic from the ELB
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Elastic Load Balancer (ELB)
resource "aws_lb" "jenkins_lb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.jenkins_subnet.id, aws_subnet.jenkins_subnet2.id]
  enable_deletion_protection = false
  depends_on         = [aws_internet_gateway.jenkins-igw]
}


# Create a security group for the Jenkins server
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins server"

  # Allow incoming HTTP (port 8080) traffic from the ELB
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    #security_groups = [aws_lb.jenkins_lb.security_groups[*].id] # Reference the ELB's security group
    #security_groups = [element(aws_lb.jenkins_lb.security_groups.*.id, 0)]
    #security_groups = [aws_security_group.jenkins-lb-sg.id]
  }

  # Allow incoming SSH (port 22) traffic from your IP or specific CIDR block
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Optionally, you can add more rules as needed for other services
}

# Define the ELB's security group rules here...

# Create a target group for the Jenkins application servers
resource "aws_lb_target_group" "jenkins_target_group" {
  name     = "jenkins-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.jenkins_vpc.id

  health_check {
    path                = "/"
    port                = 8080
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}

# Create a listener rule for the target group
resource "aws_lb_listener_rule" "jenkins_listener_rule" {
  listener_arn = aws_lb.jenkins_lb.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# Create an Amazon EFS file system
resource "aws_efs_file_system" "jenkins_efs" {
  creation_token   = "jenkins-efs" # Modify as needed
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  tags = {
    Name = "jenkins-efs"
  }
}

# Create a mount target for the EFS in your subnet
resource "aws_efs_mount_target" "jenkins_mount_target" {
  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = aws_subnet.jenkins_subnet.id
  security_groups = [aws_security_group.jenkins_sg.id]
}

# Create a Launch Template for the Jenkins server instances
resource "aws_launch_template" "jenkins_template" {
  name_prefix = "jenkins-lt-"
  description = "Launch Template for Jenkins server"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }
  instance_type          = "t2.micro"                          # Modify instance type as needed
  key_name               = aws_key_pair.capstone1-key.key_name # Replace with your SSH key pair name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  # User data to install and configure Jenkins on port 8080 and mount EFS to /var/lib/jenkins
  user_data = <<-EOF
              #!/bin/bash
              sudo amazon-linux-extras install epel
              sudo yum update -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum install fontconfig java-11-openjdk
              sudo yum install jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              
              # Mount EFS to /var/lib/jenkins
              sudo yum install -y amazon-efs-utils
              sudo mkdir -p /var/lib/jenkins
              sudo mount -t efs ${aws_efs_file_system.jenkins_efs.id}:/ /var/lib/jenkins
              sudo chown -R jenkins:jenkins /var/lib/jenkins
              echo "${aws_efs_file_system.jenkins_efs.dns_name}:/ /var/lib/jenkins efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
              # Create a data directory for Jenkins
              sudo mkdir -p /var/lib/jenkins/data
              sudo chown -R jenkins:jenkins /var/lib/jenkins/data
              EOF
}

# Access the public DNS name of the ELB
output "elb_public_dns" {
  value = aws_lb.jenkins_lb.dns_name
}