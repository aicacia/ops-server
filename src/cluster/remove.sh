#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

home_dir=$1

$dir/helm/remove.sh ${home_dir}
$dir/kubernetes/remove.sh
$dir/docker/remove.sh

apt autoremove -y