#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

read -p "Cluster name [${USER}-local]: " cluster_name
cluster_name=${cluster_name:-${USER}-local}
cluster_name=$(echo "${cluster_name}" | sed -e 's/[\ _\.]/-/g')

read -p "Delete kubectl kubelet kubeadm docker helm y/n? [n]:" delete_libs
delete_libs=${delete_libs:-n}

source $dir/functions.sh

remove_init_callback

if [[ "${cluster_type}" == "cluster" ]]; then
  ssh_user_name=root

  IFS=$'\n'
  set -f
  for node in $(cat < $(nodes_file "slave"))
  do
    ssh_user_home_dir=$(ssh ${ssh_user_name}@${node} 'echo $HOME')
    if [[ "${delete_libs}" == "y" ]]; then
      ssh ${ssh_user_name}@${node} "build/lib/remove.sh"
      ssh ${ssh_user_name}@${node} "rm -rf build"
    else
      ssh ${ssh_user_name}@${node} "build/cluster/remove.sh ${ssh_user_home_dir}"
    fi
  done

  master_node=$(head -n 1 $(nodes_file "master"))
  ssh_user_home_dir=$(ssh ${ssh_user_name}@${master_node} 'echo $HOME')
  if [[ "${delete_libs}" == "y" ]]; then
    ssh ${ssh_user_name}@${master_node} "build/lib/remove.sh"
    ssh ${ssh_user_name}@${master_node} "rm -rf build"
  else
    ssh ${ssh_user_name}@${master_node} "build/cluster/remove.sh ${ssh_user_home_dir}"
    ssh ${ssh_user_name}@${master_node} "build/flux/remove.sh ${cluster_name}"
  fi
else
  if [[ "${delete_libs}" == "y" ]]; then
    sudo $dir/lib/remove.sh
  else
    sudo $dir/cluster/remove.sh ${home_dir}
    sudo $dir/flux/remove.sh ${cluster_name}
  fi
fi

remove_end_callback