#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

cluster_type=$1
user_name=$2
home_dir=$3

$dir/docker/install.sh ${cluster_type} ${user_name}
$dir/helm/install.sh ${user_name} ${home_dir}
$dir/kubeseal/install.sh
$dir/kubernetes/install.sh