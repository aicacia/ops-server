#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

node_type=$1
tiller_namespace=$2
user_name=$3

source $dir/../../functions.sh

helm_version=2.14.1

curl -s https://storage.googleapis.com/kubernetes-helm/helm-v${helm_version}-linux-amd64.tar.gz -o helm.tar.gz
tar xf helm.tar.gz
mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64
rm helm.tar.gz

if [[ -e "$HOME/.zprofile" ]];
then
    add_environment_variable "TILLER_NAMESPACE" ${tiller_namespace} "$HOME/.zprofile"
fi
if [[ -e "$HOME/.bash_profile" ]];
then
    add_environment_variable "TILLER_NAMESPACE" ${tiller_namespace} "$HOME/.bash_profile"
fi
if [[ -e "$HOME/.profile" ]];
then
    add_environment_variable "TILLER_NAMESPACE" ${tiller_namespace} "$HOME/.profile"
fi
if [[ -e "$HOME/.bashrc" ]];
then
    add_environment_variable "TILLER_NAMESPACE" ${tiller_namespace} "$HOME/.bashrc"
fi

if [[ "${node_type}" == "master" ]];
then
    kubectl apply -f $dir/tiller.yaml
    helm init --service-account tiller --tiller-namespace ${tiller_namespace}
    kubectl taint nodes --all node-role.kubernetes.io/master-
    wait_for_deployment "tiller-deploy" "${tiller_namespace}"
else
    helm init --service-account tiller --tiller-namespace ${tiller_namespace} --client-only
fi

chown $user_name.$user_name -R $HOME/.helm