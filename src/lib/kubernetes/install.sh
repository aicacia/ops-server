#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

kubernetes_version="1.19.2"

export DEBIAN_FRONTEND=noninteractive

if ! { [ hash kubelet 2>/dev/null ] && [ hash kubeadm 2>/dev/null ] && [ hash kubectl 2>/dev/null ]; }; then
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg -s | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    apt update
    apt_version=$(apt-cache madison kubeadm | grep ${kubernetes_version} | head -1 | awk '{print $3}')
    apt install -y apt-transport-https
    apt install -y --allow-change-held-packages kubelet=${apt_version} kubeadm=${apt_version} kubectl=${apt_version}
    apt-mark hold kubelet kubeadm kubectl
fi