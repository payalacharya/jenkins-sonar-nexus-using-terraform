#!/bin/bash
set -ex # Enable debug mode and exit on error 
## e = stop on error, x = print commands



# This script installs Jenkins on an EC2 instance. It updates the package list, installs necessary dependencies, adds the Jenkins repository, and then installs Jenkins itself. Finally, it starts and enables the Jenkins service to run on boot.
# The script also ensures that the Jenkins user has passwordless sudo access, which may be necessary for certain Jenkins operations.
# Note: The line `echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoersyes` seems to have a typo. It should be `echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers` to correctly append the sudoers configuration for the Jenkins user.
sudo apt update -y
sudo apt install fontconfig openjdk-21-jre -y
sudo java -version
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo systemctl start jenkins
sudo systemctl enable jenkins