#!/bin/bash

apt purge kubeadm kubelet kubectl -y --allow-change-held-packages
rm -rf /etc/kubernetes