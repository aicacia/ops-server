#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/functions.sh
source $dir/../../.envrc