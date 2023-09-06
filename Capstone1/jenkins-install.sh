#!/bin/bash
# Install Jenkins
sudo amazon-linux-extras install epel
sudo yum update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install fontconfig java-11-openjdk
sudo yum install jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins