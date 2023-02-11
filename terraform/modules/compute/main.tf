# Variable where we will pass our Jenkins security group ID
variable "security_group" {
  description = "The security groups assigned to the Jenkins server"
}

# Variable where we will pass in the subnet ID
variable "public_subnet" {
    description = "The sublic subnet ID's assigned to the Jenkins server"
}

# Variable where we will pass in the AWS profile
variable "aws_profile" {
    description = "The AWS profile"
}

# Variable where we will pass in the AWS region
variable "aws_region" {
    description = "The AWS region"
}

# Variable where we set private key path
variable "private_key_path" {
  default = "~/the-devops-project/terraform/demo_jenkins.pem"
}

# Variable where we set playbook path
variable "playbook_path" {
  default = " ./../../ansible_templates/install_jenkins.yaml"
}

# This data store is holding the most recent Jenkins_ami 20.04 image
data "aws_ssm_parameter" "Jenkins_ami" {
  #most_recent = "true"
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Creating an EC2 instance called jenkins_server
resource "aws_instance" "jenkins_server" {
    # Setting the AMI to the ID of the Jenkins_ami 20.04 AMI from the data store
    ami = data.aws_ssm_parameter.Jenkins_ami.value

    # Setting the subnet to the public subnet we created
    subnet_id = var.public_subnet

    # Setting the instance type to t2.micro
    instance_type = "t2.micro"

    # Setting the security group to the security group we created
    vpc_security_group_ids = [var.security_group]

    # Setting the key pair name to the key pair we created
    key_name = aws_key_pair.demo_jenkins.key_name

    # Setting the user data to the bash file called install_jenkins.sh
    #user_data = "${file("${path.module}/install_jenkins.sh")}"
    
    # Added local exec
#     provisioner "local-exec" {
#     command = <<EOF
# aws --profile ${var.aws_profile} ec2 wait instance-status-ok --region ${var.aws_region} --instance-ids ${self.id} \
# && ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/install_jenkins.yaml
# EOF
#   }

    # Setting the Name tag to jenkins_server
    tags = {
        Name = "jenkins_server"
    }
    depends_on = [
    aws_instance.jenkins_server,
  ]
}

data "template_file" "ansible_inventory" {
      template = <<EOF
      [jenkins_servers]
      ${aws_instance.jenkins_server.private_ip}

      [jenkins_servers:vars]
      ansible_user=ec2-user
      ansible_ssh_private_key_file=${var.private_key_path}
      EOF

      vars = {
        private_key_path = "${var.private_key_path}"
      }
    }

provisioner "local-exec" {
    command = <<EOF
      ansible-playbook ${var.playbook_path} -i ${data.template_file.ansible_inventory.rendered}
    EOF
  }

# Creating a key pair in AWS called demo_jenkins
resource "aws_key_pair" "demo_jenkins" {
    # Naming the key demo_jenkins
    key_name = "demo_jenkins"  

    # Passing the public key of the key pair we created
    public_key = file("${path.module}/demo_jenkins.pub")
}

# Creating an Elastic IP called jenkins_eip
resource "aws_eip" "jenkins_eip" {
    # Attaching it to the jenkins_server EC2 instance
    instance = aws_instance.jenkins_server.id

    # Making sure it is inside the VPC
    vpc = true

    # Setting the tag Name to jenkins_eip
    tags = {
        Name = "jenkins_eip"
    }
    depends_on = [
    aws_instance.jenkins_server,
  ]
}
