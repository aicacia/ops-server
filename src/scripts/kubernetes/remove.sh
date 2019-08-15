#!/bin/bash

sudo rm -rf $HOME/.helm/
sudo rm /usr/local/bin/helm

sudo snap unalias kubectl

microk8s.reset
sudo snap remove microk8s

sudo apt remove --purge docker-ce docker-ce-cli containerd.io -y
sudo apt autoremove -y