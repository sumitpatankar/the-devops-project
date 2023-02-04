output "public_ip" {
  description = "THe public IP address of the Jekins server"
  value = aws_eip.jenkins_eip.public_ip
}