#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

sealed_secrets_version=0.12.5

if ! hash kubeseal 2>/dev/null; then
  wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v${sealed_secrets_version}/kubeseal-linux-amd64 -O kubeseal
  install -m 755 kubeseal /usr/local/bin/kubeseal
  rm kubeseal
fi
