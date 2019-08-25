#!/bin/bash

kubeadm reset -f
apt remove --purge kubeadm kubelet kubectl -y --allow-change-held-packages