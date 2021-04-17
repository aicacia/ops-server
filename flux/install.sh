#!/bin/bash

read -p "Github User [${GITHUB_USER}]: " owner
owner=${owner:-"${GITHUB_USER}"}

read -p "Github Repo name [ops-flux]: " repository
repository=${repository:-"ops-flux"}

read -p "cluster path [clusters/production]: " path
path=${path:-"clusters/production"}

flux bootstrap github \
  --owner=${owner} \
  --repository=${repository} \
  --path=${path}