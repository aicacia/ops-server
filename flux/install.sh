#!/bin/bash

set -e

flux_version="1.6.0"
helm_operator_version="1.2.0"
flux_name=flux
helm_operator_name=helm-operator
namespace=flux

echo ""
read -p "Flux git url [https://gitlab.com/aicacia/ops/ops-flux-local.git]: " flux_git_url
flux_git_url=${flux_git_url:-https://gitlab.com/aicacia/ops/ops-flux-local.git}

read -p "Install using git repo $flux_git_url y/n? [y]:" use_flux_git_url
use_flux_git_url=${use_flux_git_url:-y}

if [ "$use_flux_git_url" = "n" ] || [ "$use_flux_git_url" = "N" ]; then
  exit 1
fi

helm repo add fluxcd https://charts.fluxcd.io
helm repo update

kubectl create namespace ${namespace}
kubectl create -f https://raw.githubusercontent.com/fluxcd/helm-operator/${helm_operator_version}/deploy/crds.yaml

helm upgrade ${helm_operator_name} fluxcd/helm-operator \
  --version ${helm_operator_version} \
  --namespace ${namespace} \
  --install \
  --wait \
  --timeout 10m \
  --set helm.versions=v3

helm upgrade ${flux_name} fluxcd/flux \
  --version ${flux_version} \
  --namespace ${namespace} \
  --install \
  --wait \
  --timeout 10m \
  --set syncGarbageCollection.enabled=true \
  --set git.pollInterval=1m \
  --set git.user="$(git config --get user.name)" \
  --set git.email="$(git config --get user.email)" \
  --set git.readonly=true \
  --set git.url=${flux_git_url}