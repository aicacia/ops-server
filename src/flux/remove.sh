#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

cluster_name=$1

$dir/flux/remove.sh ${cluster_name}
$dir/sealed_secrets/remove.sh
$dir/cilium/remove.sh