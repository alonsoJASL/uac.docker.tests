#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '    UAC_CODE_DIR'
    >&2 echo '    EXAMPLE_FOLDER'
    exit 1
fi

PROJECT_DIR=$1
EP_DIR=$PROJECT_DIR/docker
DATA=$2

me=$(basename "$0" | awk -F. '{print $1}')
logfile=$DATA/local_$me"_"$(date +'%d%m%Y').log

# Parameters
l="endo" # which layer 
f="l"    # which fibre file (1,...,7, a, l)

echo "ENDO" > $logfile 

echo "-Copy landmark files from example dir to [$DATA/RA_$l]" >> $logfile
cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$DATA/RA_$l/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$DATA/RA_$l/Regions.txt"
echo "-finished" >> $logfile 

echo "-uac labels pipeline (Outline RAA in Mesh)" >> $logfile
echo "--labels Stage 1" >> $logfile
python $EP_DIR/entrypoint.py labels --labels-lndmrks --labels-stage 1 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "--finished (labels stage 1)" >> $logfile
echo "--Copying parameter file (RAA)" >> $logfile
python $EP_DIR/entrypoint.py getparfile --lapsolve-par carpf_laplace_RAA --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par carpf_laplace_LAA --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "--openCARP " >> $logfile
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA
echo "---finished RAA" >> $logfile
echo "--labels Stage 2" >> $logfile
python $EP_DIR/entrypoint.py labels --labels-lndmrks --labels-stage 2 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (uac labels)" >> $logfile

echo "-UAC Stage 1" >> $logfile 
python $EP_DIR/entrypoint.py uac --uac-stage 1 --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (UAC Stage 1)" >> $logfile 

echo "-Laplace solves (1)" >> $logfile 
echo "--Copying parameter files (LS, PA)" >> $logfile 
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_LS" --lapsolve-msh "RA_only_RAA" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_PA" --lapsolve-msh "RA_only_RAA" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
echo "---finished PA"  >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2
echo "---finished LR" >> $logfile 
echo "-finished (Laplace solves 1)" >> $logfile 

echo "-UAC Stage 2a" >> $logfile 
python $EP_DIR/entrypoint.py uac --uac-stage 2a --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (UAC Stage 2a)" >> $logfile 

echo "-Laplace solves (2)" >> $logfile 
echo "--Copying parameter files (LR_P, LR_A, UD_P, UD_A)" >> $logfile 
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_single_LR_P" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_single_UD_P" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_single_LR_A" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_single_UD_A" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local

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
python $EP_DIR/entrypoint.py uac --uac-stage 2b --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (UAC Stage 2b)" >> $logfile 

echo "-Fibre Mapping - single layer" >> $logfile 
python $EP_DIR/entrypoint.py fibremap --atrium ra --layer $l --fibre $f --msh RA_only_RAA --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
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
python $EP_DIR/entrypoint.py labels --labels-lndmrks --labels-stage 1 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "--finished (labels stage 1)" >> $logfile
echo "--Copying parameter file (RAA)" >> $logfile
python $EP_DIR/entrypoint.py getparfile --lapsolve-par carpf_laplace_RAA --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par carpf_laplace_LAA --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "--openCARP " >> $logfile
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA
echo "---finished RAA" >> $logfile
python $EP_DIR/entrypoint.py labels --labels-lndmrks --labels-stage 2 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (uac labels)" >> $logfile

echo "-UAC Stage 1" >> $logfile 
python $EP_DIR/entrypoint.py uac --uac-stage 1 --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (UAC Stage 1)" >> $logfile 

echo "-Laplace solves (1)" >> $logfile 
echo "--Copying parameter files (LS, PA)" >> $logfile 
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_LS" --lapsolve-msh "RA_only_RAA" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_PA" --lapsolve-msh "RA_only_RAA" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local

echo "--openCARP" >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
echo "---finished PA"  >> $logfile 
docker run --rm --volume="$DATA/RA_$l":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2
echo "---finished LR" >> $logfile 
echo "-finished (Laplace solves 1)" >> $logfile 

echo "-UAC Stage 2a" >> $logfile 
python $EP_DIR/entrypoint.py uac --uac-stage 2a --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (UAC Stage 2a)" >> $logfile 

echo "-Laplace solves (2)" >> $logfile 
echo "--Copying parameter files (LR_P, LR_A, UD_P, UD_A)" >> $logfile 
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_single_LR_P" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_single_UD_P" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_single_LR_A" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py getparfile --lapsolve-par "carpf_laplace_single_UD_A" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local

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
python $EP_DIR/entrypoint.py uac --uac-stage 2b --atrium ra --layer $l --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (UAC Stage 2b)" >> $logfile

echo "-Scalar Mapping (necessary for fibramap - bilayer - ra)" >> $logfile
# CAREFUL - this might not work all the time
python $EP_DIR/entrypoint.py scalarmap --msh RA_only_RAA --scalar-file Extra_SAN.dat --output MappedScalar_SAN.dat --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py scalarmap --msh RA_only_RAA --scalar-file Extra_CT.dat --output MappedScalar_CT.dat --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
python $EP_DIR/entrypoint.py scalarmap --msh RA_only_RAA --scalar-file Extra_PM.dat --output MappedScalar_PM.dat --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished Scalar Mapping"

echo "-Fibre Mapping - single layer" >> $logfile 
python $EP_DIR/entrypoint.py fibremap --atrium ra --layer $l --fibre $f --msh RA_only_RAA --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_" --dev-base-dir "$DATA/RA_$l" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (Fibre Mapping - single layer)" >> $logfile 

echo "-Fibre Mapping - bilayer (EPI)" >> $logfile 
python $EP_DIR/entrypoint.py fibremap --atrium ra --layer bilayer --fourch --fibre $f --msh RA_only_RAA --msh-endo Labelled --msh-epi Labelled --output "Fibre"$f"_" --dev-base-dir "$DATA/RA_epi" --dev-code-dir $PROJECT --dev-run-local
echo "-finished (Fibre Mapping - bilayer)" >> $logfile 
echo "finished EPI" >> $logfile
