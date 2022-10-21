#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '    DOCKER_TAG (3.0-alpha)'
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

echo "-Copy landmark files from example dir to [$DATA/RA_$l]" >> $logfile
cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$DATA/RA_$l/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$DATA/RA_$l/Regions.txt"
echo "-finished" >> $logfile 

echo "-uac labels pipeline (Outline RAA in Mesh)" >> $logfile
echo "--labels Stage 1" >> $logfile
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG labels --labels-lndmrks --labels-stage 1 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "--finished (labels stage 1)" >> $logfile
echo "--Copying parameter file (RAA)" >> $logfile
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par carpf_laplace_RAA
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par carpf_laplace_LAA
echo "--openCARP " >> $logfile
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA
echo "---finished RAA" >> $logfile
echo "--labels Stage 2" >> $logfile
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG labels --labels-lndmrks --labels-stage 2 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (uac labels)" >> $logfile

echo "-UAC Stage 1" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG uac --uac-stage 1 --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 1)" >> $logfile 

echo "-Laplace solves (1)" >> $logfile 
echo "--Copying parameter files (LS, PA)" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_LS" --lapsolve-msh "RA_only_RAA"
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_PA" --lapsolve-msh "RA_only_RAA"

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
echo "---finished PA"  >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2
echo "---finished LR" >> $logfile 
echo "-finished (Laplace solves 1)" >> $logfile 

echo "-UAC Stage 2a" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG uac --uac-stage 2a --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 2a)" >> $logfile 

echo "-Laplace solves (2)" >> $logfile 
echo "--Copying parameter files (LR_P, LR_A, UD_P, UD_A)" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_UD_A"

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
echo "---finished LR_Ant" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
echo "---finished LR_Post" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
echo "---finished UD_Ant" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC
echo "---finished UD_Post" >> $logfile 
echo "-finished (Laplace solves 2)" >> $logfile 

echo "-UAC Stage 2b" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG uac --uac-stage 2b --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 2b)" >> $logfile 

echo "-Fibre Mapping - single layer" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG fibremap --atrium ra --layer $l --fibre $f --msh RA_only_RAA --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_"
echo "-finished (Fibre Mapping - single layer)" >> $logfile 
echo "finished ENDO" >> $logfile 

l="epi"
echo "EPI"  >> $logfile
echo "-Copy landmark files from example dir to [$DATA/RA_$l]" >> $logfile 
cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$DATA/RA_$l/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$DATA/RA_$l/Regions.txt"
echo "-finished" >> $logfile 

echo "-uac labels pipeline (Outline RAA in Mesh)" >> $logfile
echo "--labels Stage 1" >> $logfile
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG labels --labels-lndmrks --labels-stage 1 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "--finished (labels stage 1)" >> $logfile
echo "--Copying parameter file (RAA)" >> $logfile
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par carpf_laplace_RAA
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par carpf_laplace_LAA
echo "--openCARP " >> $logfile
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA
echo "---finished RAA" >> $logfile
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG labels --labels-lndmrks --labels-stage 2 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (uac labels)" >> $logfile

echo "-UAC Stage 1" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG uac --uac-stage 1 --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 1)" >> $logfile 

echo "-Laplace solves (1)" >> $logfile 
echo "--Copying parameter files (LS, PA)" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_LS" --lapsolve-msh "RA_only_RAA"
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_PA" --lapsolve-msh "RA_only_RAA"

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
echo "---finished PA"  >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2
echo "---finished LR" >> $logfile 
echo "-finished (Laplace solves 1)" >> $logfile 

echo "-UAC Stage 2a" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG uac --uac-stage 2a --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 2a)" >> $logfile 

echo "-Laplace solves (2)" >> $logfile 
echo "--Copying parameter files (LR_P, LR_A, UD_P, UD_A)" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG getparfile --lapsolve-par "carpf_laplace_single_UD_A"

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
echo "---finished LR_Ant" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
echo "---finished LR_Post" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
echo "---finished UD_Ant" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC
echo "---finished UD_Post" >> $logfile 
echo "--finished (Laplace solves 2)" >> $logfile 

echo "-UAC Stage 2b" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG uac --uac-stage 2b --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000
echo "-finished (UAC Stage 2b)" >> $logfile

echo "-Scalar Mapping (necessary for fibramap - bilayer - ra)" >> $logfile
# CAREFUL - this might not work all the time
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG scalarmap --atrium ra --msh RA_only_RAA --scalar-file-suffix san 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG scalarmap --atrium ra --msh RA_only_RAA --scalar-file-suffix ct  
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG scalarmap --atrium ra --msh RA_only_RAA --scalar-file-suffix pm  
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG scalarmap --atrium ra --bb --msh RA_only_RAA --scalar-file-suffix bb
echo "-finished Scalar Mapping"

echo "-Fibre Mapping - single layer" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/data cemrg/uac:$TAG fibremap --atrium ra --layer $l --fibre $f --msh RA_only_RAA --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_"
echo "-finished (Fibre Mapping - single layer)" >> $logfile 

echo "-Fibre Mapping - bilayer (EPI)" >> $logfile 
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:$TAG fibremap --atrium ra --layer bilayer --fourch --fibre $f --msh RA_only_RAA --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_"
echo "-finished (Fibre Mapping - bilayer)" >> $logfile 
echo "finished EPI" >> $logfile
