# Variable that holds the CIDR block for the VPC
variable "vpc_cidr_block" {
    description = "CIDR block of the VPC"
}

# Creating the vpc and calling it demo_vpc
resource "aws_vpc" "demo_vpc" {
    # Setting the CIDR block of the VPC to the variable vpc_cidr_block
    cidr_block = var.vpc_cidr_block

    # Enabling DNS hostnames on the VPC
    enable_dns_hostnames= true

    # Setting the tag Name to demo_vpc
    tags = {
        Name = "demo_vpc"
    }
}

# Creating the Internet Gateaway and naming it demo_igw
resource "aws_internet_gateway" "demo_igw" {
    # Attaching it to the VPC called demo_vpc
    vpc_id = aws_vpc.demo_vpc.id

    # setting the Name tg to demo_igw
    tags = {
        Name = "demo_igw"
    }
}

# Creating the public route table and calling it demo_public_rt
resource "aws_route_table" "demo_public_rt" {
  # Creating it inside the demo_VPC VPC
  vpc_id = aws_vpc.demo_vpc.id

  # Adding the Internet gateway tp the route table
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }
}

# Variable that holds the CIDR block for the public subnet
variable "public_subnet_cidr_block" {
    description = "CIDR block of the public subnet"
}

# Data store that holds the available AZ's in our region
data "aws_availability_zones" "available" {
    state = "available" 
}

# Creating the public subnet and naming it demo_public_subnet
resource "aws_subnet" "demo_public_subnet" {
    # Creating it inside demo_vpc VPC
    vpc_id = aws_vpc.demo_vpc.id

    # Setting the CIDR block to the variable public_subnet_cidr_block
    cidr_block = var.public_subnet_cidr_block

    # Setting the AZ to first one in oru available AZ data store
    availability_zone = data.aws_availability_zones.available.names[0]

    # Setting the tag Name to "demo_public_subnet"
    tags = { 
        Name = "demo_public_subnet"
    }
}

# Assosiating our public subnet with oir public route table
resource "aws_route_table_association" "public" {
    # The ID of our public route table called demo_public_rt
    route_table_id = aws_route_table.demo_public_rt.id

    # The ID of our public subnet called demo_public_subnet
    subnet_id = aws_subnet.demo_public_subnet.id  
}