#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

# $dir/install-docker.sh
# $dir/install-kubernetes.sh
# $dir/install-helm.sh

$dir/../cert-manager/install.sh
$dir/../ingress/install.sh
$dir/../docker-registry/install.sh
$dir/../chartmuseum/install.sh
$dir/../kubernetes-dashboard/install.sh
$dir/../jenkins/install.sh