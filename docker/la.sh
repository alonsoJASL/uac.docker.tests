#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  PROJECT'
    >&2 echo '  EXAMPLES_DIR'
    exit 1
fi

PROJECT="$1"
EXAMPLES_DIR="$2"

# Repeating input parameters 
a="la"
MeshName="Labelled"
Landmarks="Landmarks.txt"
l="endo"
Sc="1"

for i in {1..7}
do

DATA="$EXAMPLES_DIR/la/epi/$i"

echo "=====Old UAC approximation====="
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_LS
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_PA
# python $PROJECT/uac/1_la.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled 11 13 21 23 25 27 Landmarks.txt 1
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha uac --uac-stage 1 --atrium "$a" --layer "$l" --fibre "$i" --msh "$MeshName" --tags 11 13 21 23 25 27 --landmarks "$Landmarks" --scale $Sc

echo "=====Old UAC approximation - openCARP Docker ($i)====="
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2

echo "=====New UAC====="
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_single_LR_P
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_single_UD_P
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_single_LR_A
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_single_UD_A
# python $PROJECT/uac/2a_la.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled 11 13 21 23 25 27 Landmarks.txt 1
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha uac --uac-stage 2a --atrium "$a" --layer "$l" --fibre "$i" --msh "$MeshName" --tags 11 13 21 23 25 27 --landmarks "$Landmarks" --scale $Sc

echo "=====New UAC - openCARP Docker====="
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC

echo "=====New UAC part 2====="
# python $PROJECT/uac/2b_la.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled 11 13 21 23 25 27 1
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha uac --uac-stage 2b --atrium "$a" --layer "$l" --fibre "$i" --msh "$MeshName" --tags 11 13 21 23 25 27 --landmarks "$Landmarks" --scale $Sc

# echo "=====Add fibres2====="
# python $PROJECT/uac/fibre_mapping.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled Labelled_6_1.lon Fibre_1

rm "$DATA/A_Checker_LS.vtx"
rm "$DATA/A_Checker_PA.vtx"
rm "$DATA/Ant_Strength_Test_LS1.vtx"
rm "$DATA/Ant_Strength_Test_PA1.vtx"
rm "$DATA/BorderNodes.vtx"
rm "$DATA/LSbc1.vtx"
rm "$DATA/carpf_laplace_single_LR_A.par"
rm "$DATA/carpf_laplace_single_LR_P.par"
rm "$DATA/carpf_laplace_single_UD_A.par"
rm "$DATA/carpf_laplace_single_UD_P.par"
rm "$DATA/P_Checker_LS.vtx"
rm "$DATA/PAbc2.vtx"
rm "$DATA/PAbc1.vtx"
rm "$DATA/NewInferior_PA.vtx"
rm "$DATA/NewInferior_LS.vtx"
rm "$DATA/LSPV_PA.vtx"
rm "$DATA/LSPV_LS.vtx"
rm "$DATA/LSbc2.vtx"
rm "$DATA/T2.vtk"
rm "$DATA/Test_Split.vtk"
rm "$DATA/Test_post.vtk"
rm "$DATA/Test_ant.vtk"
rm "$DATA/RSPV_PA.vtx"
rm "$DATA/RSPV_LS.vtx"
rm "$DATA/Test.vtk"
rm "$DATA/Test_sub.vtk"
rm "$DATA/Test_sub_rspv.vtk"
rm "$DATA/Test_sub_rspv_e.vtk"
rm "$DATA/Test_sub_ripv.vtk"
rm "$DATA/Test_sub_ripv_e.vtk"
rm "$DATA/Test_sub_lspv.vtk"
rm "$DATA/Test_sub_lspv_e.vtk"
rm "$DATA/Test_sub_lipv.vtk"
rm "$DATA/Test_sub_lipv_e.vtk"
rm "$DATA/Test_sub_laa.vtk"
rm "$DATA/carpf_laplace_LS.par"
rm "$DATA/carpf_laplace_PA.par"
rm "$DATA/P_Checker_PA.vtx"
rm "$DATA/Post_Strength_Test_LS1.vtx"
rm "$DATA/Post_Strength_Test_PA1.vtx"

done
