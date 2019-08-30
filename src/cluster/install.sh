#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../functions.sh

$dir/docker/install.sh
$dir/kubernetes/install.sh
$dir/helm/install.sh