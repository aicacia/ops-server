#!/bin/bash

helm_version=2.14.1
dir=$(readlink -f "$(dirname "$0")")

echo "Executing Helm installation process."

source $dir/../functions.sh

curl -s https://storage.googleapis.com/kubernetes-helm/helm-v${helm_version}-linux-amd64.tar.gz -o helm.tar.gz
tar xf helm.tar.gz
mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64
rm helm.tar.gz

kubectl create -f $dir/tiller.yaml

if [[ -e "$HOME/.zprofile" ]]
then
    add_environment_variable "TILLER_NAMESPACE" "kube-system" "$HOME/.zprofile"
fi
if [[ -e "$HOME/.bash_profile" ]]
then
    add_environment_variable "TILLER_NAMESPACE" "kube-system" "$HOME/.bash_profile"
fi
if [[ -e "$HOME/.profile" ]]
then
    add_environment_variable "TILLER_NAMESPACE" "kube-system" "$HOME/.profile"
fi

export TILLER_NAMESPACE=kube-system

helm init --service-account tiller --tiller-namespace kube-system
kubectl taint nodes --all node-role.kubernetes.io/master
chown $USER.$USER -R $HOME/.helm

wait_for_deployment "tiller-deploy" "kube-system"

helm repo update

echo "Helm installation process complete."