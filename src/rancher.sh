#!/bin/bash

src_dir=$(readlink -f "$(dirname "$0")")

bash $src_dir/install/docker.sh
bash $src_dir/install/kubectl.sh
bash $src_dir/install/rancher.sh