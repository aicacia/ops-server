#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo bash -c 'cat > /etc/docker/daemon.json << EOF
{
  "insecure-registries": ["registry.localhost"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF'

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload
sudo systemctl restart docker