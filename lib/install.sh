#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

user_name=${1:-$USER}
home_dir=${2:-$HOME}

$dir/docker/install.sh ${user_name}
$dir/helm/install.sh ${user_name} ${home_dir}
$dir/kubeseal/install.sh
$dir/kubernetes/install.sh