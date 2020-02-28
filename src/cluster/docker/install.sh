#!/bin/bash

user_name=$1
cluster_type=$2

docker_version="19.03"

export DEBIAN_FRONTEND=noninteractive

if ! hash docker 2>/dev/null; then
   apt update
   apt-get install -y \
    apt-transport-https ca-certificates curl software-properties-common gnupg2

   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

   add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      bionic \
      stable"

   apt update
   apt_version=$(apt-cache madison docker-ce | grep ${docker_version} | head -1 | awk '{print $3}')
   apt-get install -y --allow-change-held-packages docker-ce=${apt_version} docker-ce-cli=${apt_version} containerd.io
   apt-mark hold docker-ce docker-ce-cli

   if [[ "${cluster_type}" == "cluster" ]];
   then
      cat > /etc/docker/daemon.json << EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
   else
      cat > /etc/docker/daemon.json << EOF
{
  "insecure-registries": ["registry.local-k8s.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
  fi

  mkdir -p /etc/systemd/system/docker.service.d

  systemctl daemon-reload
  systemctl restart docker

  groupadd docker
  usermod -aG docker ${user_name}
  newgrp docker << EOF
exit
EOF
fi