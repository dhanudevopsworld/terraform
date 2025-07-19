terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.4"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  profile = "terraformprofile"
}

resource "aws_instance" "tomcat" {
  ami = "ami-0a1235697f4afa8a4"
  instance_type = "t2.micro"
  tags = {
    "Name" = "Tomcat_Server"
  }
}
