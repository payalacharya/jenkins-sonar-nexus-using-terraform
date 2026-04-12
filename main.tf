#####################################################################
# This file contains the main configuration for creating a VPC in AWS using Terraform.
#######################################################################
resource "aws_vpc" "myVPC" {
  cidr_block = var.cidr
  enable_dns_support   = var.dns_support
  enable_dns_hostnames = var.dns_hostnames
  tags = {
    Name = var.vpc_name
  }
}
######################################################################
#Internet Gateway
######################################################################
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = var.igw_tag
  }
}
#######################################################################
# Public Subnet
#######################################################################
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.public_subnet_cidr_1
  availability_zone = data.aws_availability_zones.available_1.names[0]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = var.public_subnet_tag_1
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.public_subnet_cidr_2
  availability_zone = data.aws_availability_zones.available_1.names[1]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = var.public_subnet_tag_2
  }
}
######################################################################
# Database Subnet
######################################################################
resource "aws_subnet" "database_subnet_1" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.database_subnet_cidr_1
  availability_zone = data.aws_availability_zones.available_1.names[2]
  map_public_ip_on_launch = false
  tags = {
    Name = var.database_subnet_tag_1
  } 
}
resource "aws_subnet" "database_subnet_2" { 
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.database_subnet_cidr_2
  availability_zone = data.aws_availability_zones.available_1.names[3]
  map_public_ip_on_launch = false
  tags = {
    Name = var.database_subnet_tag_2
  } 
}   
#######################################################################
# Public Route Table
#######################################################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = var.public_route_table_tag
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }
}
##################################################################
# Database Route Table
##################################################################
resource "aws_route_table" "database_rt" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = var.database_route_table_tag
  }
}
###############################################################
# Public Route Table Association
################################################################
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
###############################################################
# Database Route Table Association
################################################################
resource "aws_route_table_association" "database_subnet_1_association" {
  subnet_id      = aws_subnet.database_subnet_1.id
  route_table_id = aws_route_table.database_rt.id
}
resource "aws_route_table_association" "database_subnet_2_association" {
  subnet_id      = aws_subnet.database_subnet_2.id
  route_table_id = aws_route_table.database_rt.id
}
########################################################################################
# AWS SECURITY GROUP
########################################################################################

resource "aws_security_group" "our-security-group" { # This will create security group in vpc
  name        = "Our-Security-Group" # name for security group
  description = "Our Security Group" # description for SG
  vpc_id      = aws_vpc.myVPC.id # Vpc in which this SG will be created
  tags = {
    Name        = "Our-Security-Group" # Tags for security group
    Environment = var.environment # Environment for the security group
  }
  ingress {  # This is for inbound rules in SG
    from_port   = 22 # This is syntax to open port 22
    to_port     = 22
    protocol    = "tcp" # its using SSH but we specify TCP here 
    cidr_blocks = ["0.0.0.0/0"] # To allow traffic from anywhere IPV4
  }
  ingress { 
    from_port   = 80  # This is syntax to open port 80
    to_port     = 80
    protocol    = "tcp" # its using HTTP but we specify TCP here
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 8080 # This is syntax to open port 8080
    to_port     = 8080
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {  # This is syntax to open ports for outbound traffic
    from_port   = 0 # we are allowing all traffic for outbound
    to_port     = 0 # we are allowing all traffic for outbound
    protocol    = "-1" # all Protocols
    cidr_blocks = ["0.0.0.0/0"] # anywhere ipv4
    ipv6_cidr_blocks = ["::/0"] # anywhere ipv6
  }
}

resource "aws_security_group" "our-security-group-for-nexus" { # This will create security group in vpc
  name        = "Our-Security-Group-for-nexus" # name for security group
  description = "Our Security Group" # description for SG
  vpc_id      = aws_vpc.myVPC.id # Vpc in which this SG will be created
  tags = {
    Name        = "Our-Security-Group-for-nexus" # Tags for security group
    Environment = var.environment # Environment for the security group
  }
  ingress {  # This is for inbound rules in SG
    from_port   = 22 # This is syntax to open port 22
    to_port     = 22
    protocol    = "tcp" # its using SSH but we specify TCP here 
    cidr_blocks = ["0.0.0.0/0"] # To allow traffic from anywhere IPV4
  }
  ingress { 
    from_port   = 80  # This is syntax to open port 80
    to_port     = 80
    protocol    = "tcp" # its using HTTP but we specify TCP here
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 8081 # This is syntax to open port 8080
    to_port     = 8081
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {  # This is syntax to open ports for outbound traffic
    from_port   = 0 # we are allowing all traffic for outbound
    to_port     = 0 # we are allowing all traffic for outbound
    protocol    = "-1" # all Protocols
    cidr_blocks = ["0.0.0.0/0"] # anywhere ipv4
    ipv6_cidr_blocks = ["::/0"] # anywhere ipv6
  }
}

resource "aws_security_group" "our-Security-Group-for-sonar" { # This will create security group in vpc
  name        = "OOur-Security-Group-for-sonar" # name for security group
  description = "Our Security Group" # description for SG
  vpc_id      = aws_vpc.myVPC.id # Vpc in which this SG will be created
  tags = {
    Name        = "Our-Security-Group-for-sonar" # Tags for security group
    Environment = var.environment # Environment for the security group
  }
  ingress {  # This is for inbound rules in SG
    from_port   = 22 # This is syntax to open port 22
    to_port     = 22
    protocol    = "tcp" # its using SSH but we specify TCP here 
    cidr_blocks = ["0.0.0.0/0"] # To allow traffic from anywhere IPV4
  }
  ingress { 
    from_port   = 80  # This is syntax to open port 80
    to_port     = 80
    protocol    = "tcp" # its using HTTP but we specify TCP here
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 9000 # This is syntax to open port 8080
    to_port     = 9000
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {  # This is syntax to open ports for outbound traffic
    from_port   = 0 # we are allowing all traffic for outbound
    to_port     = 0 # we are allowing all traffic for outbound
    protocol    = "-1" # all Protocols
    cidr_blocks = ["0.0.0.0/0"] # anywhere ipv4
    ipv6_cidr_blocks = ["::/0"] # # Allow HTTPS from ANY IPv6 address
  }
}