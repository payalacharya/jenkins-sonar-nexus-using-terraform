######################################################################
# Availability Zones
######################################################################
data "aws_availability_zones" "available_1" {
  state = "available"
}

######################################################################
# Latest Ubuntu 22.04 LTS AMI (dynamic — no hardcoding needed)
######################################################################
data "aws_ami" "latest" {     # aws_ami helps to get AMI ID of the os
    most_recent = true  # this is the filter for most recent Ami
   
    filter {   # this is the filter for virtualization type
      name = "virtualization-type"
      values = ["hvm"]
    }
    filter {  # this is the filter for AMI name of the OS which can be found in AMI section in EC2
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
     owners = ["099720109477"]  # this is the owner of the OS, which can be found in AMI section in EC2
}
