#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

node_type=$1
cluster_name=$2
user_name=$3
home_dir=$4
discovery_token=$5
discovery_token_hash=$6
api_server_address=$7

kubeadm_version="1.15.3-00"
kubernetes_images_version="v1.15.3"
calico_version="v3.8"

export DEBIAN_FRONTEND=noninteractive

apt install -y apt-transport-https
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg -s | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubelet=${kubeadm_version} kubeadm=${kubeadm_version} kubectl=${kubeadm_version}

apt-mark hold kubelet kubeadm kubectl

if [[ "${node_type}" == "master" ]];
then
    kubeadm init --kubernetes-version=${kubernetes_images_version} --token-ttl 0

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
    cat /etc/kubernetes/admin.conf > $home_dir/.kube/config

    node_name=$(hostname)

    kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
    kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=master

    kubectl apply -f https://docs.projectcalico.org/${calico_version}/manifests/calico.yaml

    chown $user_name.$user_name -R $home_dir/.kube
elif [[ "${node_type}" == "slave" ]];
then
    kubeadm join --token "${discovery_token}" --discovery-token-ca-cert-hash "sha256:${discovery_token_hash}" ${api_server_address}
fi