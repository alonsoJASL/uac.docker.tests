#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  PROJECT'
    >&2 echo '  DATA'
    exit 1
fi

echo "[ATTENTION] This shows the commands as would be run inside your container"

PROJECT="$1"
DATA="$2"

MeshName="Labelled"
Landmarks="prodRaLandmarks.txt"
Region="prodRaRegion.txt"

echo "=======Copy parameter files================"
parfile_array=("LS" "PA" "single_LR_P" "single_UD_P" "single_LR_A" "single_UD_A")
for pf in ${parfile_array[@]}; do
    python $PROJECT/docker/entrypoint.py getparfile --lapsolve-par "carpf_laplace_"$pf --dev-code-dir $PROJECT  --debug
done

echo "=====Old UAC approximation====="
# python $PROJECT/uac/1_ra.py "$DATA/" "$PROJECT/fibre_files/ra/endo/$i/" "$PROJECT/laplace_files/" $MeshName 1 6 7 5 2 $Landmarks $Region 1
python $PROJECT/docker/entrypoint.py uac --uac-stage 1 --atrium ra --layer endo --fibre 1 --msh "$MeshName" --uac-tags 1 6 7 5 2 --landmarks $Landmarks --regions $Region --scale 1 --dev-code-dir $PROJECT  --dev-base-dir "$DATA" --debug

echo "=====Old UAC approximation - openCARP Docker====="

echo "=====New UAC====="
# python $PROJECT/uac/2a_ra.py "$DATA/" "$PROJECT/fibre_files/ra/endo/$i/" "$PROJECT/laplace_files/" $MeshName 1 6 7 5 2 $Landmarks $Region 1
python $PROJECT/docker/entrypoint.py uac --uac-stage 2a --atrium ra --layer endo --fibre 1 --msh "$MeshName" --uac-tags 1 6 7 5 2 --landmarks $Landmarks --regions $Region --scale 1 --dev-code-dir $PROJECT  --dev-base-dir "$DATA" --debug

echo "=====New UAC - openCARP Docker====="

echo "=====New UAC part 2====="
# python $PROJECT/uac/2b_ra.py "$DATA/" $MeshName 1 6 7 5 2 1
python $PROJECT/docker/entrypoint.py uac --uac-stage 2b --atrium ra --layer endo --fibre 1 --msh "$MeshName" --uac-tags 1 6 7 5 2 --landmarks $Landmarks --regions $Region --scale 1 --dev-code-dir $PROJECT  --dev-base-dir "$DATA" --debug

echo "=====Add fibres====="
# python $PROJECT/uac/fibre_mapping.py "$DATA/" "$PROJECT/fibre_files/ra/endo/$i/" "$PROJECT/laplace_files/" $MeshName Labelled.lon Fibres
python $PROJECT/docker/entrypoint.py fibremap --atrium ra --layer endo --fibre 1 --msh $MeshName --output FF_1 --dev-code-dir $PROJECT --dev-base-dir "$DATA" --debug
