#!/bin/bash

kubeadm_version="1.12.10-00"
kubernetes_images_version="v1.12.10"
calico_version="v3.7"
node_type="master"
cluster_name="${node_type}"

echo "Executing Kubernetes installation process."

apt-get install -y apt-transport-https
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg -s | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet=${kubeadm_version} kubeadm=${kubeadm_version} kubectl=${kubeadm_version}

apt-mark hold kubelet kubeadm kubectl

if [[ "${node_type}" == "master" ]]
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

    mkdir -p $HOME/.kube
    cat /etc/kubernetes/admin.conf > $HOME/.kube/config

    node_name=$(hostname)
    kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
    kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=master

    kubectl apply -f https://docs.projectcalico.org/${calico_version}/manifests/calico.yaml

    chown $USER.$USER -R $HOME/.kube
else
    kubeadm join --token "${discovery_token}" --discovery-token-ca-cert-hash "sha256:${discovery_token_hash}" ${apiserver_address} 
fi

echo "Kubernetes installation process complete."
