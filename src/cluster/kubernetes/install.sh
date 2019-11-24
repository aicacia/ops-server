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

kubeadm_version="1.16.3-00"
kubernetes_images_version="v1.16.3"

cilium_version="1.6.3"

export DEBIAN_FRONTEND=noninteractive

if !(hash kubelet 2>/dev/null || hash kubeadm 2>/dev/null || hash kubectl 2>/dev/null); then
    apt install -y apt-transport-https
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg -s | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    apt update
    apt install -y kubelet=${kubeadm_version} kubeadm=${kubeadm_version} kubectl=${kubeadm_version}
    apt-mark hold kubelet kubeadm kubectl
fi

if [[ "${node_type}" == "master" ]];
then
    if [[ "${cluster_type}" == "cluster" ]];
    then
        kubeadm init --kubernetes-version=${kubernetes_images_version} --token-ttl 0
    else
        kubeadm init --ignore-preflight-errors=Swap --config ${dir}/config.yaml
    fi

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

    mkdir -p $home_dir/.kube
    cp /etc/kubernetes/admin.conf $home_dir/.kube/config
    chown $user_name.$user_name -R $home_dir/.kube

    node_name=$(hostname)

    kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
    kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=master

    kubectl create -f https://raw.githubusercontent.com/cilium/cilium/${cilium_version}/install/kubernetes/quick-install.yaml
elif [[ "${node_type}" == "slave" ]];
then
    kubeadm join --token "${discovery_token}" --discovery-token-ca-cert-hash "sha256:${discovery_token_hash}" ${api_server_address}
fi