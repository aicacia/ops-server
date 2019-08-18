#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

$dir/../ingress/remove.sh
$dir/../docker-registry/remove.sh
$dir/../dashboard/remove.sh
$dir/../chartmuseum/remove.sh
#dir/../jenkins/remove.sh

sudo rm -rf $HOME/.helm/
sudo rm /usr/local/bin/helm

sudo snap unalias kubectl

microk8s.reset
sudo snap remove microk8s

sudo apt remove --purge docker-ce docker-ce-cli containerd.io -y
sudo apt autoremove -y