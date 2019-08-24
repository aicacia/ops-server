#!/bin/bash

kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
helm delete --purge cert-manager
helm repo remove jetstack