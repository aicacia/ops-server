#!/bin/bash

delete_libs=$1

if [[ "${delete_libs}" == "y" ]]; then
  apt purge docker-ce -y --allow-change-held-packages
  rm -rf /var/lib/docker
  rm -rf /etc/docker
  rm -rf /etc/systemd/system/docker.service.d
fi