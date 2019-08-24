#!/bin/bash

kubelet_args=/var/snap/microk8s/current/args/kubelet
dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

sudo apt update
sudo apt install \
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

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io  -y

sudo usermod -aG docker $USER

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
grep -qxF "deb https://apt.kubernetes.io/ kubernetes-xenial main" /etc/apt/sources.list.d/kubernetes.list || echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl

curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.5.0/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind $HOME/kind

kind create cluster --wait 10m

mkdir -p $HOME/.kube
cat $(kind get kubeconfig-path) > $HOME/.kube/config

curl -L https://git.io/get_helm.sh | sudo bash

kubectl create -f $dir/rbac-config.yaml

helm init --service-account tiller --history-max 200 --wait

$dir/../ingress/install.sh
$dir/../cert-manager/install.sh
$dir/../docker-registry/install.sh
$dir/../chartmuseum/install.sh
$dir/../dashboard/install.sh
#dir/../jenkins/install.sh