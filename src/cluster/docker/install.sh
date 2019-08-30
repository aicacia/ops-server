#!/bin/bash

docker_version="18.06.3"

apt update
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt update

apt_version=$(apt-cache madison docker-ce | grep ${docker_version} | head -1 | awk '{print $3}')

apt install -y \
    docker-ce=${apt_version} \
    containerd.io

apt-mark hold docker-ce

usermod -aG docker ${USER}