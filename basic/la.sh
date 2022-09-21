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
mname="Labelled"

ATRIUM="la"
LAYER="endo"
FIBRE="1"

echo "=======Copy parameter files================"
parfile_array=("LS" "PA" "single_LR_P" "single_UD_P" "single_LR_A" "single_UD_A")
for pf in ${parfile_array[@]}; do
    python $PROJECT/docker/entrypoint.py getparfile --lapsolve-par "carpf_laplace_"$pf --dev-code-dir $PROJECT  --debug
done

echo "=====Old UAC approximation====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 1 --atrium $ATRIUM --layer $LAYER --fibre $FIBRE --msh Labelled --uac-tags 11 13 21 23 25 27 --landmarks Landmarks.txt --scale 1 --dev-code-dir $PROJECT  --dev-base-dir "$DATA" --debug

echo "=====Old UAC approximation - openCARP Docker ====="

echo "=====New UAC====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2a --atrium $ATRIUM --layer $LAYER --fibre $FIBRE --msh Labelled --uac-tags 11 13 21 23 25 27 --landmarks Landmarks.txt --scale 1 --dev-code-dir $PROJECT  --dev-base-dir "$DATA" --debug

echo "=====New UAC - openCARP Docker====="

echo "=====New UAC part 2====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2b --atrium $ATRIUM --layer $LAYER --fibre $FIBRE --msh Labelled --uac-tags 11 13 21 23 25 27 --landmarks Landmarks.txt --scale 1 --dev-code-dir $PROJECT  --dev-base-dir "$DATA" --debug

echo "=====Add fibres2====="
# python $PROJECT/uac/fibre_mapping.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled Labelled_6_1.lon Fibre_1
python $PROJECT/docker/entrypoint.py fibremap --atrium $ATRIUM --layer $LAYER --fibre $FIBRE --msh Labelled --output "FF_$FIBRE"  --dev-code-dir $PROJECT  --dev-base-dir "$DATA" --debug
