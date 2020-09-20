#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

cluster_name=$1

$dir/cilium/install.sh
$dir/sealed_secrets/install.sh
$dir/flux/install.sh ${cluster_name}