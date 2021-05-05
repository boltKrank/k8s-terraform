terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37"
    }
  }
}

provider "aws" {
  profile = "puppetlabs-lms"
  region  = "ap-southeast-2"
}

#k8s master node
resource "aws_instance" "k8s_master" {
  ami           = "ami-076a5bf4a712000ed"
  instance_type = "t2.medium"

  tags = {
    Name     = "simon-k8s-master"
    lifetime = "3d"
  }
}

#k8s worker node 1
resource "aws_instance" "k8s_worker1" {
  ami           = "ami-076a5bf4a712000ed"
  instance_type = "t2.medium"

  tags = {
    Name     = "simon-k8s-worker1"
    lifetime = "3d"
  }
}

#k8s worker node 2
resource "aws_instance" "k8s_worker2" {
  ami           = "ami-076a5bf4a712000ed"
  instance_type = "t2.medium"

  tags = {
    Name     = "simon-k8s-worker2"
    lifetime = "3d"
  }
}