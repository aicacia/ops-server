#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

node_type=$1
cluster_type=$2
cluster_name=$3
user_name=$4
home_dir=$5

source $dir/../../functions.sh

helm_version=3.1.0

if !(hash helm 2>/dev/null); then
  curl -s https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz -o helm.tar.gz
  tar xf helm.tar.gz
  mv linux-amd64/helm /usr/local/bin/
  rm -rf linux-amd64
  rm helm.tar.gz
fi
