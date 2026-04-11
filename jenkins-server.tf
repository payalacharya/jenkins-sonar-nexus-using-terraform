resource "aws_instance" "jenkins-server" {   # we are creating a new instance for jenkins-server
    ami = data.aws_ami.latest.id    # dynamically fetched: latest Ubuntu 22.04 LTS
    instance_type = "t3.micro"     # This is the type of the instance we are creating
    subnet_id = aws_subnet.public_subnet_1.id   # this is the id of the subnet we are using to launch the instance
    user_data = file("./jenkins-server.sh")  # this is the script that will be executed during the creation of the instance
    key_name = "NewKey1" # this is the key name that we have created in console
    iam_instance_profile = aws_iam_instance_profile.our-instance-profile.name
    security_groups = [aws_security_group.our-security-group.id] # this is security grp in which we have openend ports
    root_block_device {
      volume_size = 20
    }

    tags = {
        Name = "jenkins-server"  # this will provide name to instance 
    }
}