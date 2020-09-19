#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
home_dir=$2
flux_version=1.20.2
helm_operator_version=1.2.0
sealed_secrets_version=0.12.5
namespace=flux

source $dir/../functions.sh

export KUBECONFIG=${home_dir}/.kube/config

echo ""
read -p "Flux git url [https://gitlab.com/aicacia/ops/ops-flux-local.git]: " flux_git_url
flux_git_url=${flux_git_url:-https://gitlab.com/aicacia/ops/ops-flux-local.git}

if ! hash kubeseal 2>/dev/null; then
  wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v${sealed_secrets_version}/kubeseal-linux-amd64 -O kubeseal
  install -m 755 kubeseal /usr/local/bin/kubeseal
  rm kubeseal
fi

kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v${sealed_secrets_version}/controller.yaml

helm repo add fluxcd https://charts.fluxcd.io
helm repo update

kubectl create namespace ${namespace}
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml --namespace ${namespace}

helm upgrade helm-operator fluxcd/helm-operator \
  --version ${helm_operator_version} \
  --namespace ${namespace} \
  --install \
  --wait \
  --timeout 60m \
  --set helm.versions=v3

helm upgrade flux fluxcd/flux \
  --version ${flux_version} \
  --namespace ${namespace} \
  --install \
  --wait \
  --timeout 60m \
  --set syncGarbageCollection.enabled=true \
  --set git.pollInterval=1m \
  --set git.user="$(git config --get user.name)" \
  --set git.email="$(git config --get user.email)" \
  --set git.readonly=true \
  --set git.url=${flux_git_url}