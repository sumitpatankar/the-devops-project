output "sg_id" {
  description = "The ID of the security group"
  value = aws_security_group.demo_jenkins_sg.id
}