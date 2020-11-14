#!/bin/bash

home_dir=$1

kubeadm reset -f
sudo rm -rf $home_dir/.kube
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

if ! hash ipvsadm 2>/dev/null; then
  sudo apt install ipvsadm
fi
sudo ipvsadm -C