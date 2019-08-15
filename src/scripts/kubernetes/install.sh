#!/bin/bash

kubelet_args=/var/snap/microk8s/current/args/kubelet
dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

sudo apt-get update
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io  -y

sudo snap install microk8s --classic

microk8s.stop

sudo sed -i '/--container-runtime/d' $kubelet_args
sudo sh -c "echo --container-runtime=docker >> $kubelet_args"

microk8s.start

microk8s.enable dns ingress storage
sudo snap alias microk8s.kubectl kubectl

microk8s.kubectl config view --raw > $HOME/.kube/config

curl -L https://git.io/get_helm.sh | sudo bash

kubectl create serviceaccount tiller --namespace kube-system
kubectl create -f $dir/tiller-clusterrolebinding.yaml

helm init --service-account tiller --wait