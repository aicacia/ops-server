#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

$dir/install-docker.sh
$dir/install-kubernetes.sh
$dir/install-helm.sh

$dir/../ingress/install.sh
$dir/../cert-manager/install.sh
$dir/../docker-registry/install.sh
$dir/../chartmuseum/install.sh
$dir/../dashboard/install.sh
# $dir/../jenkins/install.sh