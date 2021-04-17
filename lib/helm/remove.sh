#!/bin/bash

home_dir=$1

sudo rm /usr/local/bin/helm
sudo rm -r ${home_dir}/.cache/helm