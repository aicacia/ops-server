#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

cluster_type="cluster"

read -p "Cluster name: " cluster_name
cluster_name=$(echo "${cluster_name}" | sed -e 's/[\ _\.]/-/g')

source $dir/functions.sh

update_init_callback

add_variable "cluster_type" ${cluster_type}
add_variable "cluster_name" ${cluster_name}

if [[ "${cluster_type}" == "cluster" ]];
then
  ssh_user_name=root

  get_hosts "updated_slave" ${ssh_user_name}

  IFS=$'\n'
  set -f
  for node in $(cat < $(nodes_file "updated_slave"))
  do
    begin_readme_section "Slave Node ${node}"

    scp -q -r $dir ${ssh_user_name}@${node}:build
    ssh ${ssh_user_name}@${node} "build/cluster/install.sh \
      slave ${cluster_name} ${tiller_namespace} ${ssh_user_name} ${discovery_token} ${discovery_token_hash} ${api_server_address}"

    node_name=$(ssh ${ssh_user_name}@${node} hostname)
    kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
    kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=node

    add_to_readme "node_name: ${node_name}"

    echo ${node} >> $(nodes_file "slave")

    end_readme_section "Slave Node ${node}"
  done

  rm  $(nodes_file "updated_slave")
fi

update_end_callback