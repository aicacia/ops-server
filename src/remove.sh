#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

read -p "Cluster name [${USER}-local]: " cluster_name
cluster_name=${cluster_name:-${USER}-local}
cluster_name=$(echo "${cluster_name}" | sed -e 's/[\ _\.]/-/g')

source $dir/functions.sh

remove_init_callback
cp $dir/../.envrc $(envrc_file)
source $(envrc_file)

$dir/charts/remove.sh

if [[ "${cluster_type}" == "cluster" ]];
then
  ssh_user_name=root

  IFS=$'\n'
  set -f
  for node in $(cat < $(nodes_file "slave"))
  do
    ssh ${ssh_user_name}@${node} "build/cluster/remove.sh"
    ssh ${ssh_user_name}@${node} "rm -rf build"
  done

  node=$(head -n 1 $(nodes_file "master"))
  ssh ${ssh_user_name}@${node} "build/cluster/remove.sh"
  ssh ${ssh_user_name}@${node} "rm -rf build"
else
  sudo $dir/cluster/remove.sh
fi

remove_end_callback