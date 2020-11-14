#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

node_type=$1
cluster_type=$2
cluster_name=$3
user_name=$4
home_dir=$5
discovery_token=$6
discovery_token_hash=$7
api_server_address=$8

kubernetes_version="1.19.2"
export kubernetes_version=${kubernetes_version}

export DEBIAN_FRONTEND=noninteractive

if [[ "${node_type}" == "master" ]];
then
    if [[ "${cluster_type}" == "cluster" ]];
    then
        sudo kubeadm init --kubernetes-version=${kubernetes_version} --token-ttl 0
    else
        envsubst < ${dir}/local-config.tmpl.yaml > ${dir}/local-config.yaml
        sudo kubeadm init --ignore-preflight-errors=Swap --config ${dir}/local-config.yaml
        sudo rm ${dir}/local-config.yaml
    fi

    sudo mkdir -p $home_dir/.kube
    sudo cp /etc/kubernetes/admin.conf $home_dir/.kube/config
    sudo chown $user_name.$user_name -R $home_dir/.kube
    export KUBECONFIG=$home_dir/.kube/config

    node_name=$(hostname | tr '[:upper:]' '[:lower:]')
    sudo kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
    sudo kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=master
    sudo kubectl taint node ${node_name} node-role.kubernetes.io/master-
elif [[ "${node_type}" == "slave" ]];
then
    sudo kubeadm join --token "${discovery_token}" --discovery-token-ca-cert-hash "sha256:${discovery_token_hash}" ${api_server_address}
fi