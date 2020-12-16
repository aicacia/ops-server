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

read -p "Mark libs as hold y/n? [y]:" hold
hold=${hold:-y}

source $dir/functions.sh

install_init_callback

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

  ssh_user_home_dir=$(ssh ${ssh_user_name}@${master_node} 'echo $HOME')

  scp -q -r $dir ${ssh_user_name}@${master_node}:build
  ssh ${ssh_user_name}@${master_node} "./build/lib/install.sh ${ssh_user_name} ${ssh_user_home_dir}"
  ssh ${ssh_user_name}@${node} "build/cluster/install.sh master ${cluster_type} ${cluster_name} ${ssh_user_name} ${ssh_user_home_dir}"
  
  discovery_token=$(ssh ${ssh_user_name}@${master_node} "kubeadm token list | grep \"kubeadm init\" | cut -d' ' -f 1")
  add_variable "discovery_token" ${discovery_token}

  discovery_token_hash=$(ssh ${ssh_user_name}@${master_node} "openssl x509 -pubkey -in /etc/lib/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'")
  add_variable "discovery_token_hash" ${discovery_token_hash}

  scp -q ${ssh_user_name}@${master_node}:.kube/config $(cluster_home)/config.yaml
  add_environment_variable "KUBECONFIG" $(cluster_home)/config.yaml $(variable_file)

  master_node_name=$(ssh ${ssh_user_name}@${master_node} hostname)
  add_to_readme "master_node_name: ${master_node_name}"
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

    ssh_user_home_dir=$(ssh ${ssh_user_name}@${node} 'echo $HOME')

    scp -q -r $dir ${ssh_user_name}@${node}:build
    ssh ${ssh_user_name}@${node} "build/lib/install.sh ${ssh_user_name} ${ssh_user_home_dir} ${hold}"
    ssh ${ssh_user_name}@${node} "build/cluster/install.sh \
      slave ${cluster_type} ${cluster_name} ${ssh_user_name} ${ssh_user_home_dir} ${discovery_token} ${discovery_token_hash} ${api_server_address}"

    node_name=$(ssh ${ssh_user_name}@${node} hostname)
    kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
    kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=node

    add_to_readme "node_name: ${node_name}"

    end_readme_section "Slave Node ${node}"
  done

  $dir/lib/install.sh ${user_name} ${home_dir} ${hold}
  $dir/cluster/install.sh none no_cluster ${cluster_name} ${user_name} ${home_dir}
else
  $dir/lib/install.sh ${user_name} ${home_dir} ${hold}
  $dir/cluster/install.sh master ${cluster_type} ${cluster_name} ${user_name} ${home_dir}

  cp ${home_dir}/.kube/config $(cluster_home)/config.yaml
  add_environment_variable "KUBECONFIG" $(cluster_home)/config.yaml $(variable_file)

  master_node=$(kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})

  add_variable "api_server_host" ${master_node}
  add_variable "api_server_address" ${master_node}:6443

  add_host "127.0.0.1" "local-k8s.com"
  add_host "127.0.0.1" "registry.local-k8s.com"
fi

install_end_callback