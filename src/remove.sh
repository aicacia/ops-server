#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

read -p "Cluster name [${USER}-local]: " cluster_name
cluster_name=${cluster_name:-${USER}-local}
cluster_name=$(echo "${cluster_name}" | sed -e 's/[\ _\.]/-/g')

read -p "Delete kubectl kubelet kubeadm docker helm y/n? [n]:" delete_libs
cluster_name=${delete_libs:y}

source $dir/functions.sh

remove_init_callback
cp $dir/../.envrc $(envrc_file)
source $(envrc_file)

$dir/charts/remove.sh ${cluster_name}

if [[ "${cluster_type}" == "cluster" ]];
then
  ssh_user_name=root

  IFS=$'\n'
  set -f
  for node in $(cat < $(nodes_file "slave"))
  do
    ssh_user_home_dir=$(ssh ${ssh_user_name}@${master_node} 'echo $HOME')
    ssh ${ssh_user_name}@${node} "build/cluster/remove.sh ${ssh_user_home_dir} ${delete_libs}"
    ssh ${ssh_user_name}@${node} "rm -rf build"
  done

  master_node=$(head -n 1 $(nodes_file "master"))
  ssh_user_home_dir=$(ssh ${ssh_user_name}@${master_node} 'echo $HOME')
  ssh ${ssh_user_name}@${master_node} "build/cluster/remove.sh ${ssh_user_home_dir} ${delete_libs}"
  ssh ${ssh_user_name}@${master_node} "rm -rf build"
else
  sudo $dir/cluster/remove.sh ${home_dir} ${delete_libs}
fi

remove_end_callback