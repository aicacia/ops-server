#!/bin/bash

sudo apt purge kubeadm kubelet kubectl -y --allow-change-held-packages
sudo rm -rf /etc/kubernetes