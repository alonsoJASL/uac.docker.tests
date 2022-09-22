#!/bin/bash

PROJECT="$1"
EXAMPLES_DIR="$2"

for i in {1..7}
do

DATA="$EXAMPLES_DIR/la/epi/$i"

echo "=====Old UAC approximation LA====="
# python $PROJECT/uac/labels_la_1.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled 0.95 0.3 Region.txt 1
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha labels --labels-stage 1 --atrium la --layer endo --fibre $i  --labels-thresh 0.95 0.3 --msh Labelled --regions Region.txt --scale 1

# generate laplace par files
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
# python $PROJECT/uac/labels_la_2.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled 0.95 0.3 Region.txt 1
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha labels --labels-stage 2 --atrium la --layer endo --fibre $i  --labels-thresh 0.95 0.3 --msh Labelled --regions Region.txt --scale 1


DATA="$HOME/tests-refact/ra/epi/$i"

echo "=====Old UAC approximation RA====="
# python $PROJECT/uac/labels_ra_1.py "$DATA/" "$PROJECT/fibre_files/ra/endo/$i/" "$PROJECT/laplace_files/" Labelled 0.8 0.5 prodRaRegion.txt 1
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha labels --labels-stage 1 --atrium ra --layer endo --fibre $i  --labels-thresh 0.8 0.5 --msh Labelled --regions prodRaRegion.txt --scale 1

# generate laplace par files
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
# python $PROJECT/uac/labels_ra_2.py "$DATA/" "$PROJECT/fibre_files/ra/endo/$i/" "$PROJECT/laplace_files/" Labelled 0.8 0.5 prodRaRegion.txt 1
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha labels --labels-stage 2 --atrium ra --layer endo --fibre $i  --labels-thresh 0.8 0.5 --msh Labelled --regions prodRaRegion.txt --scale 1

done
