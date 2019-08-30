#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

$dir/helm/remove.sh
$dir/kubernetes/remove.sh
$dir/docker/remove.sh

apt autoremove -y