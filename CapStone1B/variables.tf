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
  description = "ami of ec2 amzoin linux2 instance"
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


#AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}


