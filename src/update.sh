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

  echo "Add/Remove[1 - Add]:"
  echo "  1 - Add"
  echo "  2 - Remove"
  read user_input
  user_input=${user_input:-1}
  update_type="install"

  if [[ "${user_input}" == "1" ]];
  then
    update_type="install"
  elif [[ "${user_input}" == "2" ]];
  then
    update_type="remove"
  else
    echo "Invalid input ${user_input}"
    exit 1
  fi 

  IFS=$'\n'
  set -f
  for node in $(cat < $(nodes_file "updated_slave"))
  do
    ssh_user_home_dir=$(ssh ${ssh_user_name}@${node} 'echo $HOME')
    
    if [[ "${update_type}" == "install" ]]; 
    then
      begin_readme_section "Slave Node ${node}"

      scp -q -r $dir ${ssh_user_name}@${node}:build

      ssh ${ssh_user_name}@${node} "build/cluster/install.sh \
        slave ${cluster_name} ${ssh_user_name} ${ssh_user_home_dir} ${tiller_namespace} ${discovery_token} ${discovery_token_hash} ${api_server_address}"

      node_name=$(ssh ${ssh_user_name}@${node} hostname)
      kubectl label nodes ${node_name} kubernetes.io/cluster-name=${cluster_name}
      kubectl label nodes ${node_name} kubeadm.alpha.kubernetes.io/role=node

      add_to_readme "node_name: ${node_name}"

      echo ${node} >> $(nodes_file "slave")

      end_readme_section "Slave Node ${node}"
    else
      ssh ${ssh_user_name}@${node} "build/cluster/remove.sh ${ssh_user_home_dir}"
      ssh ${ssh_user_name}@${node} "rm -rf build"

      node_name=$(ssh ${ssh_user_name}@${node} hostname)
      kubectl delete node ${node_name}

      sed -i "/${node}/d" $(nodes_file "slave")
    fi
  done

  rm  $(nodes_file "updated_slave")
else
  echo "Cannot add/remove nodes to local clusters"
fi

update_end_callback