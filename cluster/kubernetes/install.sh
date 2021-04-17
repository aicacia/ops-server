#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

user_name=${1:-$USER}
home_dir=${2:-$HOME}

kubernetes_version="1.20.6"
cilium_version="1.9.5"
export kubernetes_version=${kubernetes_version}

export DEBIAN_FRONTEND=noninteractive

envsubst < ${dir}/local-config.tmpl.yaml > ${dir}/local-config.yaml
sudo kubeadm init --ignore-preflight-errors=Swap --config ${dir}/local-config.yaml
sudo rm ${dir}/local-config.yaml

sudo mkdir -p $home_dir/.kube
sudo cp /etc/kubernetes/admin.conf $home_dir/.kube/config
sudo chown $user_name.$user_name -R $home_dir/.kube
export KUBECONFIG=$home_dir/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v${cilium_version}/install/kubernetes/quick-install.yaml