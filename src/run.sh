#!/bin/bash

command=$1
dir=$(readlink -f "$(dirname "$0")")

if [[ "$command" = "install" ]];
then
  $dir/scripts/kubernetes/install.sh
fi

if [[ "$command" == "remove" ]];
then
  $dir/scripts/kubernetes/remove.sh
fi