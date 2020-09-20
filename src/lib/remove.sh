#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

$dir/kubernetes/remove.sh
$dir/kubeseal/remove.sh
$dir/helm/remove.sh
$dir/docker/remove.sh

apt autoremove -y