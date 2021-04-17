#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

home_dir=${1:-$HOME}

$dir/flux/remove.sh
$dir/kubernetes/remove.sh
$dir/kubeseal/remove.sh
$dir/helm/remove.sh ${home_dir}
$dir/docker/remove.sh

sudo apt autoremove -y