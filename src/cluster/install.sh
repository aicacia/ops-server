#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

node_type=$1
cluster_name=$2
tiller_namespace=$3
user_name=$4
discovery_token=$5
discovery_token_hash=$6
api_server_address=$7

$dir/docker/install.sh ${user_name}
$dir/kubernetes/install.sh ${node_type} ${cluster_name} ${user_name} ${discovery_token} ${discovery_token_hash} ${api_server_address}
$dir/helm/install.sh ${node_type} ${tiller_namespace} ${user_name}