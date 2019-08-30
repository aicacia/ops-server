#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/functions.sh

install_init_callback

cp $dir/../.envrc ${envrc_file}
source ${envrc_file}

echo "Install Type:"
echo "  1 - Local"
echo "  2 - Cluster"
read user_input

if [[ "${user_input}" == "1" ]];
then
  add_variable "cluster_type" "local"
elif [[ "${user_input}" == "2" ]];
then
  add_variable "cluster_type" "cluster"
else
  exit_failure "Invalid input ${user_input}"
fi 

$dir/cluster/install.sh

if [[ "${node_type}" == "master" ]];
then
  $dir/charts/install.sh
fi

install_end_callback