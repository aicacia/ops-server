#!/bin/bash

read -p "URL [https://github.com/quantu-app/ops-flux]: " repository
url=${url:-"https://github.com/quantu-app/ops-flux"}

read -p "Username: [\$GITHUB_USER]" username
username=${username:-"$GITHUB_USER"}

read -p "Password: [\$GITHUB_TOKEN]" password
password=${password:-"$GITHUB_TOKEN"}

read -p "Cluster Path [clusters/production]: " path
path=${path:-"clusters/production"}

flux bootstrap git \
  --url=${url} \
  --username=${username} \
  --password=${password} \
  --token-auth=true \
  --path=${path}