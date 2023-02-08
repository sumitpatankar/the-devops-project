# Variable where we will pass our Jenkins security group ID
variable "security_group" {
  description = "The security groups assigned to the Jenkins server"
}

# Variable where we will pass in the subnet ID
variable "public_subnet" {
    description = "The sublic subnet ID's assigned to the Jenkins server"
}

# This data store is holding the most recent Jenkins_ami 20.04 image
data "aws_ami" "Jenkins_ami" {
  most_recent = "true"

  filter {
    name = "name"
    values = ["/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Creating an EC2 instance called jenkins_server
resource "aws_instance" "jenkins_server" {
    # Setting the AMI to the ID of the Jenkins_ami 20.04 AMI from the data store
    ami = data.aws_ami.Jenkins_ami.id

    # Setting the subnet to the public subnet we created
    subnet_id = var.public_subnet

    # Setting the instance type to t2.micro
    instance_type = "t2.micro"

    # Setting the security group to the security group we created
    vpc_security_group_ids = [var.security_group]

    # Setting the key pair name to the key pair we created
    key_name = aws_key_pair.demo_jenkins.key_name

    # Setting the user data to the bash file called install_jenkins.sh
    user_data = "${file("${path.module}/install_jenkins.sh")}"

    # Setting the Name tag to jenkins_server
    tags = {
        Name = "jenkins_server"
    }
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
}
