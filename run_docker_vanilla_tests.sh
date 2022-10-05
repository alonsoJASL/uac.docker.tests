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

$BASE_DIR/docker/la.sh $TEST_DIRECTORY/vanilla endo 
$BASE_DIR/docker/la.sh $TEST_DIRECTORY/vanilla epi 

$BASE_DIR/docker/ra.sh $TEST_DIRECTORY/vanilla endo 
$BASE_DIR/docker/ra.sh $TEST_DIRECTORY/vanilla epi 

$BASE_DIR/docker/labelling.sh $TEST_DIRECTORY/vanilla

$BASE_DIR/docker/fibre_mapping.sh $TEST_DIRECTORY/vanilla la 
$BASE_DIR/docker/fibre_mapping.sh $TEST_DIRECTORY/vanilla ra 

