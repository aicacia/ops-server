#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

node_type=$1
cluster_name=$2
user_name=$3
home_dir=$4
tiller_namespace=$5
discovery_token=$6
discovery_token_hash=$7
api_server_address=$8

$dir/docker/install.sh ${user_name}
$dir/kubernetes/install.sh ${node_type} ${cluster_name} ${user_name} ${home_dir} ${discovery_token} ${discovery_token_hash} ${api_server_address}
$dir/helm/install.sh ${node_type} ${cluster_name} ${user_name} ${home_dir} ${tiller_namespace}