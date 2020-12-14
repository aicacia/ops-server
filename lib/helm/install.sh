#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

user_name=$1
home_dir=$2
helm_version="3.4.2"

if ! hash helm 2>/dev/null; then
  sudo curl -s https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz -o helm.tar.gz
  sudo tar xf helm.tar.gz
  sudo mv linux-amd64/helm /usr/local/bin/
  sudo rm -rf linux-amd64
  sudo rm helm.tar.gz
fi

sudo chown ${user_name}.${user_name} ${home_dir}/.cache/helm