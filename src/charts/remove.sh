#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

$dir/jenkins/remove.sh
$dir/kubernetes-dashboard/remove.sh
$dir/chartmuseum/remove.sh
$dir/docker-registry/remove.sh
$dir/ingress/remove.sh
$dir/cert-manager/remove.sh