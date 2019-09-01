#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

home_dir=$1

kubectl delete -f $dir/tiller.yaml
rm -rf $home_dir/.helm/
rm /usr/local/bin/helm