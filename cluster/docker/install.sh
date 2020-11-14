#!/bin/bash

cluster_type=$1

docker_version="19.03"

export DEBIAN_FRONTEND=noninteractive

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
  "insecure-registries": ["registry.localhost"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
fi

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload
sudo systemctl restart docker