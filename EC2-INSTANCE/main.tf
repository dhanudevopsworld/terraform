# Terraform configuration for AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4"
    }
  }
}

# Configure the AWS provider with the desired region and profile.
# The region is set to ap-south-1 and the profile is set to terraformprofile
provider "aws" {
  region  = "ap-south-1"
  profile = "terraformprofile"
}

# This Terraform configuration creates two EC2 instances running Tomcat and an Ansible server to manage them.
# The Tomcat instances are created with a specific AMI and instance type, and they are tagged for identification.
# The Ansible server is also created with the same AMI and instance type, and it uses a remote-exec provisioner to install Ansible and configure it to manage the Tomcat instances.
# The Ansible server will also copy the necessary SSH key and playbook to the instance.
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
# This resource creates an Ansible server instance that will manage the Tomcat instances.
# It uses a remote-exec provisioner to install Ansible and configure it to manage the Tomcat instances.
# The Ansible server will also copy the necessary SSH key and playbook to the instance.
resource "aws_instance" "Ansible_Server" {
  ami           = "ami-0a1235697f4afa8a4"
  instance_type = "t2.micro"
  key_name      = "DhanuDevops"

  tags = {
    "Name" = "Ansible_Server"
  }
  depends_on = [aws_instance.tomcat]
 # The provisioners below are used to install Ansible on the Ansible server and configure it to manage the Tomcat instances.
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Desktop/DhanuPem/DhanuDevops.pem")
      host        = self.public_ip
    }

    script = "${path.module}/installansible.sh"
  }
# The provisioners below are used to copy the SSH key and Ansible playbook to the Ansible server.
  provisioner "file" {
    source      = "~/Desktop/DhanuPem/DhanuDevops.pem"
    destination = "/home/ec2-user/DhanuDevops.pem"
  
 # The connection block below is used to connect to the Ansible server using SSH. 
  connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Desktop/DhanuPem/DhanuDevops.pem")
      host        = self.public_ip
    }
  }
# The provisioner below is used to copy the Ansible playbook to the Ansible server.
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
# The provisioner below is used to run the Ansible playbook on the Ansible server.
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Desktop/DhanuPem/DhanuDevops.pem")
      host        = self.public_ip
    }
# The commands below are executed on the Ansible server to set up the Ansible inventory and run the playbook.
    # It sets the permissions for the SSH key, creates an Ansible inventory file, and runs the Ansible playbook to install Tomcat on the Tomcat instances.
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
# Output the private IPs of the Tomcat instances.
output "private_ips" {
  value = [for instance in aws_instance.tomcat : instance.private_ip]
}
# Output the public IPs of the Tomcat instances.
output "public_ips" {
  value = [for instance in aws_instance.tomcat : instance.public_ip]
}













































