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

kubernetes_version="1.17.3"
cilium_version="1.7"

export DEBIAN_FRONTEND=noninteractive

if ! hash kubeadm 2>/dev/null; then
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg -s | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    apt update
    apt_version=$(apt-cache madison kubeadm | grep ${kubernetes_version} | head -1 | awk '{print $3}')
    apt install -y apt-transport-https
    apt install -y --allow-change-held-packages kubelet=${apt_version} kubeadm=${apt_version} kubectl=${apt_version}
    apt-mark hold kubelet kubeadm kubectl
fi

if [[ "${node_type}" == "master" ]];
then
    if [[ "${cluster_type}" == "cluster" ]];
    then
        kubeadm init --kubernetes-version=${kubernetes_version} --token-ttl 0
    else
        kubeadm init --ignore-preflight-errors=Swap --config ${dir}/local-config.yaml
    fi

    mkdir -p $home_dir/.kube
    cp /etc/kubernetes/admin.conf $home_dir/.kube/config
    chown $user_name.$user_name $home_dir/.kube/config
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
    
    if [[ "${cluster_type}" != "cluster" ]];
    then
        kubectl taint node ${node_name} node-role.kubernetes.io/master-
    fi

    kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v${cilium_version}/install/kubernetes/quick-install.yaml
elif [[ "${node_type}" == "slave" ]];
then
    kubeadm join --token "${discovery_token}" --discovery-token-ca-cert-hash "sha256:${discovery_token_hash}" ${api_server_address}
fi