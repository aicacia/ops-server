#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

home_dir=$1

$dir/kubernetes/remove.sh ${home_dir}

systemctl daemon-reload
systemctl restart docker
systemctl enable docker

apt autoremove -y
apt autoclean -y