variable "aws_region" {
  default = "us-east-2"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "my_IP" {
  description = "Your IP adderss"
  type        = string
  sensitive   = true
}

# Security Group
variable "jenkins_ingress_rules" {
  type    = list(number)
  default = [8080, 22]
}