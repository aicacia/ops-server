#!/bin/bash

set -e

cilium_version="1.9.0"
namespace=kube-system

helm repo add cilium https://helm.cilium.io/

helm upgrade cilium cilium/cilium \
  --version ${cilium_version} \
  --namespace=${namespace} \
  --install \
  --wait \
  --timeout 10m