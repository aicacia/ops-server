#!/bin/bash

home_dir=$1

kubeadm reset -f
rm -rf $home_dir/.kube
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

if ! hash ipvsadm 2>/dev/null; then
  apt install ipvsadm
fi
ipvsadm -C