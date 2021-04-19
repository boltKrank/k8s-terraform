terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-076a5bf4a712000ed"
  instance_type = "t2.medium"

  tags = {
    Name = "ubuntu18-simon"
    lifetime = "3d"
  }
}