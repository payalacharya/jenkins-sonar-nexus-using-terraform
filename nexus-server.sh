#!/bin/bash
set -ex

sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Wait for docker to be ready
sleep 10

sudo docker run -d -p 8081:8081 --name nexus-server \
  -e INSTALL4J_ADD_VM_PARAMS="-Xms256m -Xmx512m -XX:MaxDirectMemorySize=512m" \
  sonatype/nexus3

