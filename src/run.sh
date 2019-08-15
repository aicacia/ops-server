#!/bin/bash

command=$1
src_dir=$(readlink -f "$(dirname "$0")")

if [ $command == "install" ];
then
  $src_dir/scripts/kubernetes/install.sh
fi

if [ $command == "remove" ];
then
  $src_dir/scripts/kubernetes/remove.sh
fi