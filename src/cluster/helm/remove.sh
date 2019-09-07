#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

home_dir=$1
delete_libs=$2

helm reset --force

if [[ "${delete_libs}" == "y" ]]; then
  rm /usr/local/bin/helm
fi