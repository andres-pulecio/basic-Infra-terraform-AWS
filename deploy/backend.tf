terraform {
  backend "s3" {
    bucket = "basic-infra-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}