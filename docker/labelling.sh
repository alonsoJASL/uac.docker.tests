#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  EXAMPLES_DIR'
    exit 1
fi

EXAMPLES_DIR="$1"

for i in {1..7}
do

DATA="$EXAMPLES_DIR/la/epi/$i"
echo "===="
echo "$DATA"
echo "===="

echo "=====Old UAC approximation LA====="
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha labels --labels-stage 1 --atrium la --layer endo --fibre $i  --labels-thresh 0.95 0.3 --msh Labelled --regions Region.txt --scale 1

docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PV1"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PV2"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PV3"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PV4"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LAA"

echo "=====Old UAC approximation LA - openCARP Docker ($i)====="
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV1.par -simID MV_PV1
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV2.par -simID MV_PV2
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV3.par -simID MV_PV3
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV4.par -simID MV_PV4
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LAA.par -simID MV_LAA

echo "=====New UAC LA====="
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha labels --labels-stage 2 --atrium la --layer endo --fibre $i  --labels-thresh 0.95 0.3 --msh Labelled --regions Region.txt --scale 1


DATA="$EXAMPLES_DIR/ra/epi/$i"
echo "===="
echo "$DATA"
echo "===="

echo "=====Old UAC approximation RA====="
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha labels --labels-stage 1 --atrium ra --layer endo --fibre $i  --labels-thresh 0.8 0.5 --msh Labelled --regions prodRaRegion.txt --scale 1

docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PV2"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PV3"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PV4"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LAA"

echo "=====Old UAC approximation RA - openCARP Docker ($i)====="
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV2.par -simID MV_PV2
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV3.par -simID MV_PV3
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV4.par -simID MV_PV4
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LAA.par -simID MV_LAA

echo "=====New UAC RA====="
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha labels --labels-stage 2 --atrium ra --layer endo --fibre $i  --labels-thresh 0.8 0.5 --msh Labelled --regions prodRaRegion.txt --scale 1

done
