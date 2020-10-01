#!/bin/bash

flux_name=flux
helm_operator_name=helm-operator
namespace=flux

helm delete ${flux_name} --namespace ${namespace}
helm delete ${helm_operator_name} --namespace ${namespace}
helm repo remove fluxcd

kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml --namespace ${namespace}
kubectl delete namespace ${namespace}