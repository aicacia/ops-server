#!/bin/bash

sealed_secrets_version=0.12.5

kubectl delete -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v${sealed_secrets_version}/controller.yaml