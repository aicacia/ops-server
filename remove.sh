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

    ssh ${ssh_user_name}@${node} "build/cluster/remove.sh ${ssh_user_home_dir}"

    if [[ "${delete_libs}" == "y" ]]; then
      ssh ${ssh_user_name}@${node} "build/lib/remove.sh"
      ssh ${ssh_user_name}@${node} "rm -rf build"
    fi
  done

  master_node=$(head -n 1 $(nodes_file "master"))
  ssh_user_home_dir=$(ssh ${ssh_user_name}@${master_node} 'echo $HOME')

  ssh ${ssh_user_name}@${master_node} "build/cluster/remove.sh ${ssh_user_home_dir}"

  if [[ "${delete_libs}" == "y" ]]; then
    ssh ${ssh_user_name}@${master_node} "build/lib/remove.sh"
    ssh ${ssh_user_name}@${master_node} "rm -rf build"
  fi
else
  $dir/cluster/remove.sh ${home_dir}

  if [[ "${delete_libs}" == "y" ]]; then
    $dir/lib/remove.sh
  fi
fi

remove_end_callback