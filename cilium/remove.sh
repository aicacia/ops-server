#!/bin/bash

cilium_version="1.8.5"
namespace=kube-system

helm delete cilium --namespace ${namespace}
helm repo remove cilium