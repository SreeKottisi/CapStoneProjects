variable "REGION" {
  default = "us-west-2"
}

variable "ZONE1" {
  default = "us-west-2a"
}

variable "ZONE2" {
  default = "us-west-2b"
}

variable "ZONE3" {
  default = "us-west-2c"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-west-2 = "ami-002c2b8d1f5b1eb47"
    us-west-1 = "ami-026257f4f39c28af8"
  }
}

variable "USER" {
  default = "ec2-user"
}

variable "PUB_KEY" {
  default = "capstone-project1-key.pub"
}

variable "PRIV_KEY" {
  default = "capstone-project1-key"
}

variable "MYIP" {
  default = "45.25.181.98/32"
}