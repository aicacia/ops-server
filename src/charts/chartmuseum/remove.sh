#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

helm delete --purge chartmuseum
helm repo remove chartmuseum
helm plugin remove push