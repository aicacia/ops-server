#!/bin/bash

user_name=$1

docker_version="19.03"

export DEBIAN_FRONTEND=noninteractive

if ! hash docker 2>/dev/null; then
   apt update
   apt-get install apt-transport-https ca-certificates curl software-properties-common

   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

   add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
   apt update

   apt_version=$(apt-cache madison docker-ce | grep ${docker_version} | head -1 | awk '{print $3}')
   apt-get install -y docker-ce=${apt_version}
   apt-mark hold docker-ce

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

   mkdir -p /etc/systemd/system/docker.service.d

   systemctl daemon-reload
   systemctl restart docker
fi

usermod -aG docker ${user_name}