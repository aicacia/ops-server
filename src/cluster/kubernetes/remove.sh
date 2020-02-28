#!/bin/bash

home_dir=$1
delete_libs=$2

kubeadm reset -f
rm -rf $home_dir/.kube
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

if [[ "${delete_libs}" == "y" ]]; then
  apt purge kubeadm kubelet kubectl -y --allow-change-held-packages
  rm -rf /etc/kubernetes
fi