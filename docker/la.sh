#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  EXAMPLES_DIR'
    >&2 echo '  atrium_layer {endo,epi}'
    exit 1
fi

EXAMPLES_DIR="$1"
me=$(basename "$0" | awk -F. '{print $1}')
logfile=$EXAMPLES_DIR/$me"_"$(date +'%m%d%Y').log

# Repeating input parameters 
a="la"
MeshName="Labelled"
Landmarks="Landmarks.txt"
l="$2"
Sc="1"

for i in {1..7}
do
# i=1

DATA="$EXAMPLES_DIR/la/$l/$i"
echo "$DATA" >> $logfile

echo "=====Old UAC approximation=====" >> $logfile
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_LS
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_PA
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha uac --uac-stage 1 --atrium "$a" --layer "$l" --fibre "$i" --msh "$MeshName" --tags 11 13 21 23 25 27 --landmarks "$Landmarks" --scale $Sc

echo "=====Old UAC approximation - openCARP Docker ($i)=====" >> $logfile
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2

echo "=====New UAC=====" >> $logfile
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_single_LR_P
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_single_UD_P
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_single_LR_A
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_single_UD_A
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha uac --uac-stage 2a --atrium "$a" --layer "$l" --fibre "$i" --msh "$MeshName" --tags 11 13 21 23 25 27 --landmarks "$Landmarks" --scale $Sc

echo "=====New UAC - openCARP Docker=====" >> $logfile
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2=====" >> $logfile
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha uac --uac-stage 2b --atrium "$a" --layer "$l" --fibre "$i" --msh "$MeshName" --tags 11 13 21 23 25 27 --landmarks "$Landmarks" --scale $Sc

done
