#!/bin/bash
set -ex

sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

sleep 10

# Run SonarQube
sudo docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_JAVA_OPTS="-Xms256m -Xmx512m" \
  sonarqube:lts-community