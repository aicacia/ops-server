#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
namespace=ci

source $dir/../../functions.sh

helm uninstall chartmuseum -n ${namespace}
helm repo remove chartmuseum