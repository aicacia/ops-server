#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

home_dir=$1

$dir/kubernetes/remove.sh ${home_dir}

sudo systemctl daemon-reload
sudo systemctl restart docker

sudo apt autoremove -y
sudo apt autoclean -y