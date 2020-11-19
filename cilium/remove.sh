#!/bin/bash

namespace=kube-system

helm uninstall cilium --namespace ${namespace}
helm repo remove cilium