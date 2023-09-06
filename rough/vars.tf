variable "PUB_KEY" {
  default = "capstone-project1-key.pub"
}

variable "PRIV_KEY" {
  default = "capstone-project1-key"
}

resource "aws_key_pair" "capstone1-key" {
  key_name   = "capstone1-key"
  public_key = file(var.PUB_KEY)
}