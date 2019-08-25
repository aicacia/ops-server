#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

$dir/../ingress/remove.sh
$dir/../cert-manager/remove.sh
$dir/../docker-registry/remove.sh
$dir/../chartmuseum/remove.sh
$dir/../dashboard/remove.sh
#dir/../jenkins/remove.sh

kubectl delete -f $dir/tiller.yaml

rm -rf $HOME/.helm/
rm /usr/local/bin/helm