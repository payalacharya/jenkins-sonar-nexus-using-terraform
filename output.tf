output "vpc_id" {
  value = aws_vpc.myVPC.id
}
output "Instance-id" {
  value = aws_instance.nexus_server.id
}
output "nexus_public_ip" {
  value = aws_instance.nexus_server.public_ip
}
