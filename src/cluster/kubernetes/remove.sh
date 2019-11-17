#!/bin/bash

delete_libs=$1

kubeadm reset -f
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

if [[ "${delete_libs}" == "y" ]]; then
  apt purge kubeadm kubelet kubectl -y --allow-change-held-packages
fi