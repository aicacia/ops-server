#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

helm delete --purge jenkins

kubectl delete -f $dir/jenkins-persistent-volume-claim.yaml
kubectl delete -f $dir/jenkins-persistent-volume.yaml