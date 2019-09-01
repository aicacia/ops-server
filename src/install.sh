#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

echo "Install Type [1 - Local]:"
echo "  1 - Local"
echo "  2 - Cluster"
read user_input
user_input=${user_input:-1}

cluster_name=${USER}-local

if [[ "${user_input}" == "1" ]];
then
  cluster_type="local"
elif [[ "${user_input}" == "2" ]];
then
  cluster_type="cluster"
else
  echo "Invalid input ${user_input}"
  exit 1
fi 

if [[ "${cluster_type}" == "cluster" ]];
then
  read -p "Cluster name: " cluster_name
  cluster_name=$(echo "${cluster_name}" | sed -e 's/[\ _\.]/-/g')
fi

source $dir/functions.sh

install_init_callback
cp $dir/../.envrc $(envrc_file)
source $(envrc_file)

add_variable "cluster_type" ${cluster_type}
add_variable "cluster_name" ${cluster_name}

if [[ "${cluster_type}" == "cluster" ]];
then
  ssh_user_name=root

  get_host "master" ${ssh_user_name}
  get_hosts "slave" ${ssh_user_name}

  master_node=$(head -n 1 $(nodes_file "master"))

  begin_readme_section "Master Node ${master_node}"

  add_variable "api_server_host" ${master_node}
  add_variable "api_server_address" ${master_node}:6443
  add_environment_variable "API_SERVER_HOST" ${master_node} $(envrc_file)

  scp -q -r $dir ${ssh_user_name}@${master_node}:build
  ssh ${ssh_user_name}@${master_node} "./build/cluster/install.sh master ${cluster_name} ${tiller_namespace} ${ssh_user_name}"
  
  discovery_token=$(ssh ${ssh_user_name}@${master_node} "kubeadm token list | grep \"kubeadm init\" | cut -d' ' -f 1")
  add_variable "discovery_token" ${discovery_token}

  discovery_token_hash=$(ssh ${ssh_user_name}@${master_node} "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'")
  add_variable "discovery_token_hash" ${discovery_token_hash}

  scp -q ${ssh_user_name}@${master_node}:.kube/config $(cluster_home)/${cluster_name}
  add_environment_variable "KUBECONFIG" $(cluster_home)/${cluster_name} $(envrc_file)
  export KUBECONFIG=$(cluster_home)/${cluster_name}

  add_to_readme "api_server_address: ${api_server_address}"
  add_to_readme "discovery_token: ${discovery_token}"
  add_to_readme "discovery_token_hash: ${discovery_token_hash}"
  add_to_readme "add a node to the cluster"
  add_to_readme "  kubeadm join --token "${discovery_token}" --discovery-token-ca-cert-hash "sha256:${discovery_token_hash}" ${api_server_address}"

  end_readme_section "Master Node ${master_node}"

  IFS=$'\n'
  set -f
  for node in $(cat < $(nodes_file "slave"))
  do
    begin_readme_section "Slave Node ${node}"

    scp -q -r $dir ${ssh_user_name}@${node}:build
    ssh ${ssh_user_name}@${node} "build/cluster/install.sh \
      slave ${cluster_name} ${tiller_namespace} ${ssh_user_name} ${discovery_token} ${discovery_token_hash} ${api_server_address}"

    node_name=$(ssh ${ssh_user_name}@${node} hostname)
    kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
    kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=node

    add_to_readme "node_name: ${node_name}"

    end_readme_section "Slave Node ${node}"
  done

  sudo $dir/cluster/install.sh no_cluster ${cluster_name} ${tiller_namespace} ${user_name}
  $dir/charts/install.sh ${cluster_name}
else
  sudo $dir/cluster/install.sh master ${cluster_name} ${tiller_namespace} ${user_name}

  master_node=$(kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})

  add_variable "api_server_host" ${master_node}
  add_variable "api_server_address" ${master_node}:6443
  add_environment_variable "API_SERVER_HOST" ${master_node} ${envrc_file}

  $dir/charts/install.sh ${cluster_name}
fi

install_end_callback