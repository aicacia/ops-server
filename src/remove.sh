#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/functions.sh

remove_init_callback

cp $dir/../.envrc ${envrc_file}
source ${envrc_file}

$dir/cluster/remove.sh

remove_end_callback