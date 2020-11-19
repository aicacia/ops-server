#!/bin/bash

helm_operator_version="1.2.0"
flux_name=flux
helm_operator_name=helm-operator
namespace=flux

helm uninstall ${flux_name} --namespace ${namespace}
helm uninstall ${helm_operator_name} --namespace ${namespace}
helm repo remove fluxcd

kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/${helm_operator_version}/deploy/crds.yaml --namespace ${namespace}
kubectl delete namespace ${namespace}