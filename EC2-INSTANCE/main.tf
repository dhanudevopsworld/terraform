terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4"
    }
  }
}


provider "aws" {
  region  = "ap-south-1"
  profile = "terraformprofile"
}






resource "aws_instance" "tomcat" {
  ami           = "ami-0a1235697f4afa8a4"
  count         = 2
  instance_type = "t2.micro"
  key_name      = "DhanuDevops"

  tags = {
    "Name" = "tomcat-${count.index + 1}"
  }
}

locals {
  tomcat_inventory_lines = [
    for ip in aws_instance.tomcat[*].private_ip :
    "echo '${ip} ansible_user=ec2-user ansible_ssh_private_key_file=/home/ec2-user/DhanuDevops.pem' >> /home/ec2-user/hosts"
  ]
}

resource "aws_instance" "Ansible_Server" {
  ami           = "ami-0a1235697f4afa8a4"
  instance_type = "t2.micro"
  key_name      = "DhanuDevops"

  tags = {
    "Name" = "Ansible_Server"
  }
  depends_on = [aws_instance.tomcat]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Desktop/DhanuPem/DhanuDevops.pem")
      host        = self.public_ip
    }

    script = "${path.module}/installansible.sh"
  }

  provisioner "file" {
    source      = "~/Desktop/DhanuPem/DhanuDevops.pem"
    destination = "/home/ec2-user/DhanuDevops.pem"
  
  
  connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Desktop/DhanuPem/DhanuDevops.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "~/Desktop/terrafor demo/EC2-INSTANCE/EC2-INSTANCE/installtomcat.yaml"
    destination = "/home/ec2-user/installtomcat.yaml"
  connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Desktop/DhanuPem/DhanuDevops.pem")
      host        = self.public_ip
    }
  
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Desktop/DhanuPem/DhanuDevops.pem")
      host        = self.public_ip
    }

    inline = concat(
      [
        "chmod 400 /home/ec2-user/DhanuDevops.pem",
        "echo '[web]' > /home/ec2-user/hosts"
      ],
      local.tomcat_inventory_lines,
      [
        "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ec2-user/hosts /home/ec2-user/installtomcat.yaml"
      ]
    )
  }
}

output "private_ips" {
  value = [for instance in aws_instance.tomcat : instance.private_ip]
}

















































