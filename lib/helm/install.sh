#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

user_name=$1
home_dir=$2
helm_version=3.3.3

if ! hash helm 2>/dev/null; then
  curl -s https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz -o helm.tar.gz
  tar xf helm.tar.gz
  mv linux-amd64/helm /usr/local/bin/
  rm -rf linux-amd64
  rm helm.tar.gz
fi

chown ${user_name}.${user_name} ${home_dir}/.cache/helm