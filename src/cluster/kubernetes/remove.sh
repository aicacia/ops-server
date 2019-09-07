#!/bin/bash

delete_libs=$1

kubeadm reset -f

if [[ "${delete_libs}" == "y" ]]; then
  apt remove --purge kubeadm kubelet kubectl -y --allow-change-held-packages
fi