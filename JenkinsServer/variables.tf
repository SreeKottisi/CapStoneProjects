#variables.tf

#This is a Environement variable 
variable "environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "Jenkins"
}

# This is a Region Variable
variable "aws_region" {
  description = "AWS region name"
  type        = string
  default     = "us-west-2"
}

/*EC2 variables can be used to store values such as the AMI ID, instance type, and VPC ID of an 
EC2 instance. These values in our Terraform code are used to create and configure EC2 instances. */

variable "ami" {
  description = "ami of ec2 ubantu instance"
  type        = string
  default     = "ami-002c2b8d1f5b1eb47"
}

# Launch Template and ASG Variables
variable "instance_type" {
  description = "launch template EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "PUB_KEY" {
  default = "capstone1-key.pub"
}

variable "PRIV_KEY" {
  default = "capstone1-key"
}

variable "USER" {
  default = "ec2-user"
}

#This user data variable indicates that the script configures Apache on a server.
variable "ubantu_ec2_user_data" {
  description = "variable indicates that the script configures Jenkins on a server"
  type        = string
  default     = <<EOF
#!/bin/bash
sudo apt update && sudo apt upgrade -y

sudo apt install default-jdk -y

sudo java -version

sudo mkdir -p /usr/share/keyrings

sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee   /usr/share/keyrings/jenkins-keyring.asc > /dev/null

sudo echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y

sudo apt install jenkins -y 

sudo systemctl start jenkins --no-pager -l

sudo systemctl enable --now jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
EOF
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

#  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  # Mount EFS to /var/lib/jenkins
  sudo yum install -y amazon-efs-utils
  
  

  # Create a data directory for Jenkins
  sudo mkdir -p /var/lib/jenkins/data
  sudo chown -R jenkins:jenkins /var/lib/jenkins/data
  #update the  fs id from step1
  sudo mount -t efs -o tls fs-045759ea362791ce7:/ /var/lib/jenkins/data

# install jenkins server
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  sudo yum install jenkins -y
  sudo systemctl start jenkins
  sudo systemctl enable jenkins

  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
EOF
}

/*This VPC can then be used to deploy resources that need to be accessible from the internet or from other resources in the VPC.
This variable defines the CIDR block for the VPC. The default value is 10.0.0.0/16.
*/

# VPC Variables
variable "capstone1-vpc-cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.10.0.0/16"
}

#These Public subnets are used for resources that need to be accessible from the internet
variable "capstone1-public-subnet-cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["10.10.0.0/24", "10.10.2.0/24"]
}

#These Private subnets can be used to deploy resources that do not need to be accessible from the internet.
variable "capstone1-private-subnet-cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["10.10.3.0/24", "10.10.4.0/24"]
}


