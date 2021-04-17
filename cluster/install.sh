#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

user_name=${1:-$USER}
home_dir=${2:-$HOME}

$dir/docker/install.sh
$dir/kubernetes/install.sh ${user_name} ${home_dir}