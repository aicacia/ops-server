#!/bin/bash

delete_libs=$1

if [[ "${delete_libs}" == "y" ]]; then
  apt remove --purge docker-ce docker-ce-cli containerd.io -y --allow-change-held-packages
fi