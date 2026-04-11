resource "aws_instance" "nexus_server" {
  # create a Nexus server instance in the existing VPC
  ami           = data.aws_ami.latest.id # dynamically fetched: latest Ubuntu 22.04 LTS
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet_1.id
  user_data     = file("./nexus-server.sh")
  key_name      = var.key_name
  security_groups = [aws_security_group.our-security-group-for-nexus.id]

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "nexus-server"
  }
}
