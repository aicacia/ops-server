#!/bin/bash

cilium_version="1.8.4"
namespace=kube-system

helm delete cilium --namespace ${namespace}
helm repo remove cilium