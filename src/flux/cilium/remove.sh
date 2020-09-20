#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

cilium_version="1.8.3"

kubectl delete -f https://raw.githubusercontent.com/cilium/cilium/v${cilium_version}/install/kubernetes/quick-install.yaml