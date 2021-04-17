#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

sealed_secrets_version="0.15.0"

if ! hash kubeseal 2>/dev/null; then
  sudo wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v${sealed_secrets_version}/kubeseal-linux-amd64 -O kubeseal
  sudo install -m 755 kubeseal /usr/local/bin/kubeseal
  sudo rm kubeseal
fi
