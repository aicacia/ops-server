#!/bin/bash

sudo apt purge docker-ce docker-ce-cli -y --allow-change-held-packages
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker
sudo rm -rf /etc/systemd/system/docker.service.d
sudo groupdel docker