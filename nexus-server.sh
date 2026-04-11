#!/bin/bash
set -ex

sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Create 2GB swap file
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Wait for docker to be ready
sleep 10

sudo docker run -d -p 8081:8081 --name nexus-server \
  -e INSTALL4J_ADD_VM_PARAMS="-Xms256m -Xmx512m -XX:MaxDirectMemorySize=512m" \
  sonatype/nexus3