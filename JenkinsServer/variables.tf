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
  default     = "ami-03f65b8614a860c29"
}

# Launch Template and ASG Variables
variable "instance_type" {
  description = "launch template EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "PUB_KEY" {
  default = "capstone-project1-key.pub"
}

variable "PRIV_KEY" {
  default = "capstone-project1-key"
}

variable USER {
  default = "ec2-user"
}

#This user data variable indicates that the script configures Apache on a server.
variable "ec2_user_data" {
  description = "variable indicates that the script configures Jenkins on a server"
  type        = string
  default     = <<EOF
#!/bin/bash

# Update the package list and install OpenJDK 11 (required by Jenkins)
sudo apt-get update -y
sudo apt-get install -y openjdk-11-jdk

# Download and install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -y
sudo apt-get install -y jenkins

# Start Jenkins service
sudo systemctl start jenkins

# Enable Jenkins to start on boot
sudo systemctl enable jenkins

# Print the initial admin password for Jenkins (you'll need this to complete setup)
echo "Initial Jenkins admin password:"
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


