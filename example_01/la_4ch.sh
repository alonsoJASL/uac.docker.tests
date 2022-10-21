#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '    DOCKER_VERSION_TAG {$TAG, [github-sha]}'
    >&2 echo '    EXAMPLE_FOLDER'
    exit 1
fi

TAG=$1
DATA=$2

me=$(basename "$0" | awk -F. '{print $1}')
logfile=$DATA/$me"_"$(date +'%d%m%Y').log

# Parameters
l="endo" # which layer
f="l"    # which fibre file (1,...,7, a, l)

echo "Using docker version $TAG "
echo "Using docker version $TAG " >> $logfile
echo "ENDO" > $logfile 
echo "-Copy landmark files from example dir to [$DATA/LA_$l]" >> $logfile
cp "$DATA/Landmarks/LA/prodRaLandmarks.txt" "$DATA/LA_$l/Landmarks.txt"
cp "$DATA/Landmarks/LA/prodRaRegion.txt" "$DATA/LA_$l/Regions.txt"
echo "-finished" >> $logfile 

echo "-UAC Stage 1" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG uac --uac-stage 1 --atrium la --layer $l --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 1)" >> $logfile 

echo "-Laplace solves (1)" >> $logfile 
echo "--Copying parameter files (LS, PA)" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_LS" --lapsolve-msh "LA_only"
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_PA" --lapsolve-msh "LA_only"

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
echo "---finished PA"  >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2
echo "---finished LR" >> $logfile 
echo "-finished (Laplace solves 1)" >> $logfile 

echo "-UAC Stage 2a" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG uac --uac-stage 2a --atrium la --layer $l --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 2a)" >> $logfile 

echo "-Laplace solves (2)" >> $logfile 
echo "--Copying parameter files (LR_P, LR_A, UD_P, UD_A)" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_UD_A"

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
echo "---finished LR_Ant" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
echo "---finished LR_Post" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
echo "---finished UD_Ant" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC
echo "---finished UD_Post" >> $logfile 
echo "-finished (Laplace solves 2)" >> $logfile 

echo "-UAC Stage 2b" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG uac --uac-stage 2b --atrium la --layer $l --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 2b)" >> $logfile 

echo "-Fibre Mapping - single layer" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG fibremap --atrium la --layer $l --fibre $f --msh LA_only --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_"
echo "-finished (Fibre Mapping - single layer)" >> $logfile 
echo "finished ENDO" >> $logfile 

l="epi"
echo "-EPI"  >> $logfile 
echo "-Copy landmark files from example dir to [$DATA/LA_$l]" >> $logfile 
cp "$DATA/Landmarks/LA/prodRaLandmarks.txt" "$DATA/LA_$l/Landmarks.txt"
cp "$DATA/Landmarks/LA/prodRaRegion.txt" "$DATA/LA_$l/Regions.txt"
echo "-finished" >> $logfile 

echo "-UAC Stage 1" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG uac --uac-stage 1 --atrium la --layer $l --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 1)" >> $logfile 

echo "-Laplace solves (1)" >> $logfile 
echo "--Copying parameter files (LS, PA)" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_LS" --lapsolve-msh "LA_only"
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_PA" --lapsolve-msh "LA_only"

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
echo "---finished PA"  >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2
echo "---finished LR" >> $logfile 
echo "-finished (Laplace solves 1)" >> $logfile 

echo "-UAC Stage 2a" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG uac --uac-stage 2a --atrium la --layer $l --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 2a)" >> $logfile 

echo "-Laplace solves (2)" >> $logfile 
echo "--Copying parameter files (LR_P, LR_A, UD_P, UD_A)" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_UD_A"

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
echo "---finished LR_Ant" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
echo "---finished LR_Post" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
echo "---finished UD_Ant" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC
echo "---finished UD_Post" >> $logfile 
echo "--finished (Laplace solves 2)" >> $logfile 

echo "-UAC Stage 2b" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG uac --uac-stage 2b --atrium la --layer $l --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 2b)" >> $logfile 

echo "-Scalar Mapping (BB) - not necessary for overall output" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG scalarmap --atrium la --bb --msh LA_only --scalar-file-suffix bb
echo "-finished Scalar Mapping (BB)" >> $logfile 

echo "-Fibre Mapping - single layer" >> $logfile 
docker run --rm --volume="$DATA/LA_$l":/data cemrg/uac:$TAG fibremap --atrium la --layer $l --fibre $f --msh LA_only --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_"
echo "-finished (Fibre Mapping - single layer)" >> $logfile 

echo "-Fibre Mapping - bilayer (EPI)" >> $logfile 
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:$TAG fibremap --atrium la --layer bilayer --fourch --fibre $f --msh LA_only --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_"
echo "-finished (Fibre Mapping - bilayer)" >> $logfile 
echo "finished EPI" >> $logfile
