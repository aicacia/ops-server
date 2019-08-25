#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

kubectl delete -f $dir/jenkins-pv-pvc.yaml
helm delete --purge jenkins