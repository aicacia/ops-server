#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

kubernetes_version="1.19.4"

export DEBIAN_FRONTEND=noninteractive

if ! { [ hash kubelet 2>/dev/null ] && [ hash kubeadm 2>/dev/null ] && [ hash kubectl 2>/dev/null ]; }; then
    sudo curl https://packages.cloud.google.com/apt/doc/apt-key.gpg -s | sudo apt-key add -
    sudo echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    sudo apt update
    apt_version=$(sudo apt-cache madison kubeadm | grep ${kubernetes_version} | head -1 | awk '{print $3}')
    sudo apt install -y apt-transport-https
    sudo apt install -y --allow-change-held-packages kubelet=${apt_version} kubeadm=${apt_version} kubectl=${apt_version}
    sudo apt-mark hold kubelet kubeadm kubectl
fi