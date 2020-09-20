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

export DEBIAN_FRONTEND=noninteractive

if [[ "${node_type}" == "master" ]];
then
    if [[ "${cluster_type}" == "cluster" ]];
    then
        kubeadm init --kubernetes-version=${kubernetes_version} --token-ttl 0
    else
        export kubernetes_version=${kubernetes_version}
        envsubst < ${dir}/local-config.tmpl.yaml > ${dir}/local-config.yaml
        kubeadm init --ignore-preflight-errors=Swap --config ${dir}/local-config.yaml
        rm ${dir}/local-config.yaml
    fi

    mkdir -p $home_dir/.kube
    cp /etc/kubernetes/admin.conf $home_dir/.kube/config
    chown $user_name.$user_name -R $home_dir/.kube
    export KUBECONFIG=$home_dir/.kube/config

    echo "Checking API server availability..."
    for i in {1..150}; do # timeout for 5 minutes
        ./kubectl get po &> /dev/null
        if [ $? -ne 1 ]
        then
            echo "API server is available"
            break
        fi
        echo "Waiting..."
        sleep 2
    done

    node_name=$(hostname | tr '[:upper:]' '[:lower:]')
    kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
    kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=master
    kubectl taint node ${node_name} node-role.kubernetes.io/master-
elif [[ "${node_type}" == "slave" ]];
then
    kubeadm join --token "${discovery_token}" --discovery-token-ca-cert-hash "sha256:${discovery_token_hash}" ${api_server_address}
fi