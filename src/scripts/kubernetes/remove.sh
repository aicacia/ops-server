#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

$dir/../ingress/remove.sh
$dir/../cert-manager/remove.sh
$dir/../docker-registry/remove.sh
$dir/../chartmuseum/remove.sh
$dir/../dashboard/remove.sh
#dir/../jenkins/remove.sh

kind delete cluster

sudo rm -rf $HOME/.helm/
sudo rm /usr/local/bin/helm

sudo rm $HOME/bin/kind

sudo apt remove --purge kubectl -y

sudo apt remove --purge docker-ce docker-ce-cli containerd.io -y
sudo apt autoremove -y