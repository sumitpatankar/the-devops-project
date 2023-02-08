output "public_ip" {
  description = "The public IP address of the Jekins server"
  value = aws_eip.jenkins_eip.public_ip
}