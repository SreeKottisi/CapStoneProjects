terraform {
  backend "s3" {
    bucket = "terraform-state-capstone1"
    key    = "terraform/capstone1-jenkins"
    region = "us-west-2"
  }
}