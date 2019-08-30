#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

kubectl delete -f $dir/tiller.yaml

rm -rf $HOME/.helm/
rm /usr/local/bin/helm