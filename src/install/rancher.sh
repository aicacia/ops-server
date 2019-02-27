#!/bin/bash

src_dir=$(readlink -f "$(dirname "$0")")/../..

cp $src_dir/.envrc.example $src_dir/.envrc
source $src_dir/.envrc.example

sudo docker run -d \
  --restart=unless-stopped \
  --name=rancher \
  -p 80:80 \
  -p 443:443 \
  -v /opt/rancher:/var/lib/rancher \
  rancher/rancher \
  --acme-domain $RANCHER_HOST

