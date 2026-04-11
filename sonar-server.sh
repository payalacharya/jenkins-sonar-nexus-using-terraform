#!/bin/bash
set -ex

sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Create 4GB swap (SonarQube needs more than Nexus)
# sudo fallocate -l 4G /swapfile
# sudo chmod 600 /swapfile
# sudo mkswap /swapfile
# sudo swapon /swapfile
# echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# # Required kernel settings for SonarQube
# sudo sysctl -w vm.max_map_count=262144
# sudo sysctl -w fs.file-max=65536
# echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
# echo 'fs.file-max=65536' | sudo tee -a /etc/sysctl.conf

sleep 10

# Run SonarQube
sudo docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_JAVA_OPTS="-Xms256m -Xmx512m" \
  sonarqube:lts-community