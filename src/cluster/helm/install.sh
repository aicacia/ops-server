#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../../functions.sh

helm_version=2.14.1

begin_readme_section "helm"

curl -s https://storage.googleapis.com/kubernetes-helm/helm-v${helm_version}-linux-amd64.tar.gz -o helm.tar.gz
tar xf helm.tar.gz
mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64
rm helm.tar.gz

kubectl apply -f $dir/tiller.yaml

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

export TILLER_NAMESPACE=${tiller_namespace}

if [[ "${node_type}" == "master" ]];
then
    helm init --service-account tiller --tiller-namespace ${tiller_namespace}
    kubectl taint nodes --all node-role.kubernetes.io/master-
    wait_for_deployment "tiller-deploy" "${tiller_namespace}"
else
    helm init --service-account tiller --tiller-namespace ${tiller_namespace} --client-only
fi

chown $USER.$USER -R $HOME/.helm

add_to_readme "Tiller namespace: ${tiller_namespace}"

end_readme_section "helm"