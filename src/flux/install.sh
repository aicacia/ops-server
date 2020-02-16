#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
flux_name=flux
flux_version=1.2.0
helm_operator_name=helm-operator
helm_operator_version=0.7.0
namespace=flux

source $dir/../functions.sh

echo ""
read -p "Flux git url [https://gitlab.com/aicacia/ops/ops-flux-local.git]: " flux_git_url
flux_git_url=${flux_git_url:-https://gitlab.com/aicacia/ops/ops-flux-local.git}

helm repo add fluxcd https://charts.fluxcd.io
helm repo update

begin_readme_section ${flux_name}

kubectl create namespace ${namespace}
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml --namespace ${namespace}

helm upgrade ${helm_operator_name} fluxcd/helm-operator \
  --version ${helm_operator_version} \
  --install \
  --namespace ${namespace} \
  --set helm.versions=v3

wait_for_deployment ${helm_operator_name} ${namespace}

helm install ${flux_name} fluxcd/flux \
  --version ${flux_version} \
  --namespace ${namespace} \
  --set git.pollInterval=1m \
  --set git.user="$(git config --get user.name)" \
  --set git.email="$(git config --get user.email)" \
  --set git.readonly=true \
  --set git.url=${flux_git_url}

wait_for_deployment ${flux_name} ${namespace}

add_to_readme ""

add_to_readme "get the token for the dashboard"
add_to_readme "===="
add_to_readme "kubectl -n kubernetes-dashboard describe secrets kubernetes-dashboard-token"

add_to_readme ""

add_to_readme "pushing to registry"
add_to_readme "===="
add_to_readme "/etc/docker/daemon.json"
add_to_readme "{"
add_to_readme "  insecure-registries" : ["registry.localhost"]
add_to_readme "}"

end_readme_section ${flux_name}