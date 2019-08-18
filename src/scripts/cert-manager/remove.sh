#!/bin/bash

helm delete --purge cert-manager
helm repo remove jetstack