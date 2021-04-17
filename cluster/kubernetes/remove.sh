#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

home_dir=${1:-$HOME}

cilium_version="1.9.5"

kubectl delete -f https://raw.githubusercontent.com/cilium/cilium/v${cilium_version}/install/kubernetes/quick-install.yaml

sudo kubeadm reset -f
sudo rm -r ${home_dir}/.kube
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

if ! hash ipvsadm 2>/dev/null; then
  sudo apt install ipvsadm
fi
sudo ipvsadm -C