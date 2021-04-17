#!/bin/bash

user_name=$1

docker_version="20.10.6"

export DEBIAN_FRONTEND=noninteractive

if ! hash docker 2>/dev/null; then
  sudo apt update
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg2

  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  
  sudo apt update
  apt_version=$(sudo apt-cache madison docker-ce | grep ${docker_version} | head -1 | awk '{print $3}')
  sudo apt install -y --allow-change-held-packages docker-ce=${apt_version} docker-ce-cli=${apt_version} containerd.io

  sudo apt-mark hold docker-ce docker-ce-cli

  sudo groupadd docker
  sudo usermod -aG docker ${user_name}
  sudo newgrp docker << EOF
exit
EOF

  sudo systemctl enable docker
fi