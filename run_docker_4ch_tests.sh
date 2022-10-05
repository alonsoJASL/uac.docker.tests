#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  TESTS_DIRECTORY'
    exit 1
fi

BASE_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )
me=$(basename "$0" | awk -F. '{print $1}')

TEST_DIRECTORY=$1

$BASE_DIR/docker/4ch/1_extract_surfaces.sh $HOME/dev/python/uac $TEST_DIRECTORY/4ch/4ch 

$BASE_DIR/docker/4ch/2_loop_biatrial_automated_labarthe_fibres.sh $TEST_DIRECTORY/4ch/4ch 