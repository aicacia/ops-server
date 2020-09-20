#!/bin/bash

apt purge docker-ce docker-ce-cli -y --allow-change-held-packages
rm -rf /var/lib/docker
rm -rf /etc/docker
rm -rf /etc/systemd/system/docker.service.d
groupdel docker