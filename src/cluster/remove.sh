#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

home_dir=$1
delete_libs=$2

$dir/helm/remove.sh ${home_dir} ${delete_libs}
$dir/kubernetes/remove.sh ${delete_libs}
$dir/docker/remove.sh ${delete_libs}

apt autoremove -y