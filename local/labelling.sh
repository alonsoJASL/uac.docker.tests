#!/bin/bash

for i in {1..7}
do

PROJECT="$HOME/uac-refact"
DATA="$HOME/tests-refact/la/epi/$i"

echo "=====Old UAC approximation LA====="
python $PROJECT/uac/labels_la_1.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled 0.95 0.3 Region.txt 1

# generate laplace par files
cp "$PROJECT/laplace_files/carpf_laplace_PV1.par" "$DATA/carpf_laplace_PV1.par"
cp "$PROJECT/laplace_files/carpf_laplace_PV2.par" "$DATA/carpf_laplace_PV2.par"
cp "$PROJECT/laplace_files/carpf_laplace_PV3.par" "$DATA/carpf_laplace_PV3.par"
cp "$PROJECT/laplace_files/carpf_laplace_PV4.par" "$DATA/carpf_laplace_PV4.par"
cp "$PROJECT/laplace_files/carpf_laplace_LAA.par" "$DATA/carpf_laplace_LAA.par"

echo "=====Old UAC approximation LA - openCARP Docker ($i)====="
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV1.par -simID MV_PV1
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV2.par -simID MV_PV2
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV3.par -simID MV_PV3
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV4.par -simID MV_PV4
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LAA.par -simID MV_LAA

echo "=====New UAC LA====="
python $PROJECT/uac/labels_la_2.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled 0.95 0.3 Region.txt 1


DATA="$HOME/tests-refact/ra/epi/$i"

echo "=====Old UAC approximation RA====="
python $PROJECT/uac/labels_ra_1.py "$DATA/" "$PROJECT/fibre_files/ra/endo/$i/" "$PROJECT/laplace_files/" Labelled 0.8 0.5 prodRaRegion.txt 1

# generate laplace par files
cp "$PROJECT/laplace_files/carpf_laplace_PV2.par" "$DATA/carpf_laplace_PV2.par"
cp "$PROJECT/laplace_files/carpf_laplace_PV3.par" "$DATA/carpf_laplace_PV3.par"
cp "$PROJECT/laplace_files/carpf_laplace_PV4.par" "$DATA/carpf_laplace_PV4.par"
cp "$PROJECT/laplace_files/carpf_laplace_LAA.par" "$DATA/carpf_laplace_LAA.par"

echo "=====Old UAC approximation RA - openCARP Docker ($i)====="
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV2.par -simID MV_PV2
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV3.par -simID MV_PV3
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PV4.par -simID MV_PV4
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LAA.par -simID MV_LAA

echo "=====New UAC RA====="
python $PROJECT/uac/labels_ra_2.py "$DATA/" "$PROJECT/fibre_files/ra/endo/$i/" "$PROJECT/laplace_files/" Labelled 0.8 0.5 prodRaRegion.txt 1

done
