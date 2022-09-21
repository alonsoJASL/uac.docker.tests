#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied: '
    >&2 echo '  PROJECT_DIR'
    >&2 echo '  DATA_DIR'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )

PROJECT=$1
DATA=$2

echo "==============="
echo "====LA-ENDO===="
echo "==============="
laendo_dir="$DATA/LA_endo"
mname="LA_only" # used in both endo and epi 

cp "$DATA/Landmarks/LA/prodRaLandmarks.txt" "$laendo_dir/Landmarks.txt"
cp "$DATA/Landmarks/LA/prodRaRegion.txt" "$laendo_dir/Regions.txt"

parfile_array=("single_LR_P" "single_UD_P" "single_LR_A" "single_UD_A" "LS_4Ch" "PA_4Ch" "LAA_4Ch")
echo "Copying file: carpf_laplace_* files"
for pf in ${parfile_array[@]}; do 
    python $PROJECT/docker/entrypoint.py getparfile --lapsolve-par "carpf_laplace_$pf" --code-dir $PROJECT --base-dir "$laendo_dir/"
done

echo "call to meshtool"
meshtool convert -imsh=$laendo_dir/LA_endo.vtk -omsh="$laendo_dir/$mname" -ofmt=carp_txt -scale=1000

echo "=====Old UAC approximation====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 1 --atrium la --fourch --layer endo --msh "$mname" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$laendo_dir/"


echo "Call to openCARP (PA)"
docker run --rm --volume="$laendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA_4Ch.par -simID PA_UAC_N2
echo "Call to openCARP (LS)"
docker run --rm --volume="$laendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS_4Ch.par -simID LR_UAC_N2

echo "=====New UAC====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2a --atrium la --fourch --layer endo --msh "$mname" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$laendo_dir/"

echo "Call to openCARP single_LR_A"
docker run --rm --volume="$laendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
echo "Call to openCARP single_LR_P"
docker run --rm --volume="$laendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
echo "Call to openCARP single_UD_A"
docker run --rm --volume="$laendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
echo "Call to openCARP single_UD_P"
docker run --rm --volume="$laendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2b --atrium la --fourch --layer endo --msh "$mname" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$laendo_dir/"


echo "==============="
echo "====LA-EPI====="
echo "==============="
laepi_dir="$DATA/LA_epi"

cp "$DATA/Landmarks/LA/prodRaLandmarks.txt" "$DATA/LA_epi/Landmarks.txt"
cp "$DATA/Landmarks/LA/prodRaRegion.txt" "$DATA/LA_epi/Regions.txt"

parfile_array=("single_LR_P" "single_UD_P" "single_LR_A" "single_UD_A" "LS_4Ch" "PA_4Ch" "LAA_4Ch")
echo "Copying file: carpf_laplace_* files"
for pf in ${parfile_array[@]}; do 
    python $PROJECT/docker/entrypoint.py getparfile --lapsolve-par "carpf_laplace_$pf" --code-dir $PROJECT --base-dir "$laepi_dir/"
done

echo "Call to meshtool"
meshtool convert -imsh=$laepi_dir/LA_epi.vtk -omsh=$laepi_dir/"$mname" -ofmt=carp_txt -scale=1000

echo "=====Old UAC approximation====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 1 --atrium la --fourch --layer epi --msh "$mname" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$laepi_dir/"

echo "Call to openCARP (PA)"
docker run --rm --volume="$laepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA_4Ch.par -simID PA_UAC_N2
echo "Call to openCARP (LS)"
docker run --rm --volume="$laepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS_4Ch.par -simID LR_UAC_N2


echo "=====New UAC====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2a --atrium la --fourch --layer epi --msh "$mname" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$laepi_dir/"

echo "Call to openCARP single_LR_A"
docker run --rm --volume="$laepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
echo "Call to openCARP single_LR_P"
docker run --rm --volume="$laepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
echo "Call to openCARP single_UD_A"
docker run --rm --volume="$laepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
echo "Call to openCARP single_UD_P"
docker run --rm --volume="$laepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2b --atrium la --fourch --layer epi --msh "$mname" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$laepi_dir/"

echo "=====Add fibres2 ====="
python $PROJECT/docker/entrypoint.py fibremap --atrium la --layer epi --fibre l --msh "$mname" --output Fibre_Labarthe --code-dir $PROJECT --base-dir "$laepi_dir/"

echo "=====Add LAT field====="
python $PROJECT/docker/entrypoint.py sims --lat-type normal --lat-file LAT_Spiral4_B.dat --msh Fibre_L --code-dir $PROJECT --base-dir "$laepi_dir/"


# #repeat this for RA epi!
echo "==============="
echo "====RA-EPI====="
echo "==============="
raepi_dir="$DATA/RA_epi"
mname="RA_only" # used in both endo and epi 

cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$raepi_dir/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$raepi_dir/Regions.txt"

parfile_array=("single_LR_P.par" "single_UD_P.par" "single_LR_A.par" "single_UD_A.par"  "LS_4Ch_RA.par" "PA_4Ch_RA.par"  "LAA_4Ch.par" "RAA.par")
echo "Copying file: carpf_laplace_* files"
for pf in ${parfile_array[@]}; do 
    python $PROJECT/docker/entrypoint.py getparfile --lapsolve-par "carpf_laplace_$pf" --code-dir $PROJECT --base-dir "$raepi_dir/"
done

meshtool convert -imsh=$raepi_dir/RA_epi.vtk -omsh=$raepi_dir/RA_only -ofmt=carp_txt -scale=1000

# NEED TO SPLIT AS BEFORE & AFTER CARP
python $PROJECT/docker/entrypoint.py labels --labels-lndmrks --labels-stage 1 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raepi_dir/"

echo "Call to openCARP RAA"
docker run --rm --volume="$raepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA

python $PROJECT/docker/entrypoint.py labels --labels-lndmrks --labels-stage 2 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raepi_dir/"

echo "=====Old UAC approximation====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 1 --atrium ra --fourch --layer epi --msh $mname"_RAA" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raepi_dir/"

echo "Call to openCARP (PA)"
docker run --rm --volume="$raepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA_4Ch_RA.par -simID PA_UAC_N2
echo "Call to openCARP (LS"
docker run --rm --volume="$raepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS_4Ch_RA.par -simID LR_UAC_N2


echo "=====New UAC====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2a --atrium ra --fourch --layer epi --msh $mname"_RAA" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raepi_dir/"

echo "Call to openCARP (single_LR_A) "
docker run --rm --volume="$raepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
echo "Call to openCARP (single_LR_P) "
docker run --rm --volume="$raepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
echo "Call to openCARP (single_UD_A) "
docker run --rm --volume="$raepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
echo "Call to openCARP (single_UD_P) "
docker run --rm --volume="$raepi_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2b --atrium ra --fourch --layer epi --msh $mname"_RAA" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raepi_dir/"


echo "==============="
echo "====RA-ENDO===="
echo "==============="
raendo_dir="$DATA/RA_endo"

cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$raendo_dir/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$raendo_dir/Regions.txt"

parfile_array=("single_LR_P.par" "single_UD_P.par" "single_LR_A.par" "single_UD_A.par" "LS_4Ch_RA.par" "PA_4Ch_RA.par" "LAA_4Ch.par" "RAA.par")
echo "Copying file: carpf_laplace_* files"
for pf in ${parfile_array[@]}; do 
    python $PROJECT/docker/entrypoint.py getparfile --lapsolve-par "carpf_laplace_$pf" --code-dir $PROJECT --base-dir "$raendo_dir/"
done

meshtool convert -imsh=$raendo_dir/RA_endo.vtk -omsh=$raendo_dir/RA_only -ofmt=carp_txt -scale=1000

# # NEED TO SPLIT AS BEFORE & AFTER CARP
python $PROJECT/docker/entrypoint.py labels --labels-lndmrks --labels-stage 1 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raendo_dir/"

echo "Call to openCARP (RAA)"
docker run --rm --volume="$raendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA

python $PROJECT/docker/entrypoint.py labels --labels-lndmrks --labels-stage 2 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raendo_dir/"

echo "=====Old UAC approximation====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 1 --atrium ra --fourch --layer endo --msh $mname"_RAA" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raendo_dir/"

echo "Call to openCARP (PA)"
docker run --rm --volume="$raendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA_4Ch_RA.par -simID PA_UAC_N2
echo "Call to openCARP (LS)"
docker run --rm --volume="$raendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS_4Ch_RA.par -simID LR_UAC_N2

echo "=====New UAC====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2a --atrium ra --fourch --layer endo --msh $mname"_RAA" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raendo_dir/"

echo "Call to openCARP (single_LR_A)"
docker run --rm --volume="$raendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
echo "Call to openCARP (single_LR_P)"
docker run --rm --volume="$raendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
echo "Call to openCARP (single_UD_A)"
docker run --rm --volume="$raendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
echo "Call to openCARP (single_UD_P)"
docker run --rm --volume="$raendo_dir":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
python $PROJECT/docker/entrypoint.py uac --uac-stage 2b --atrium ra --fourch --layer endo --msh $mname"_RAA" --landmarks Landmarks.txt --regions Regions.txt --scale 1000 --code-dir $PROJECT --base-dir "$raendo_dir/"

#Fibres next

echo "=====Add fibres2 (EPI) ====="
python $PROJECT/docker/entrypoint.py fibremap --atrium ra --layer epi --fibre l --msh $mname"_RAA" --output Fibre_Labarthe --code-dir $PROJECT --base-dir "$raepi_dir/"

echo "=====Add LAT field ====="
python $PROJECT/docker/entrypoint.py sims --lat-type normal --lat-file LAT_Spiral4_B.dat --msh Fibre_Labarthe --code-dir $PROJECT --base-dir "$raepi_dir/"

python $PROJECT/docker/entrypoint.py scalarmap --atrium ra --layer epi --fibre l --msh RA_only_RAA --scalar-file Extra_SAN.dat --output MappedScalar_SAN
python $PROJECT/docker/entrypoint.py scalarmap --atrium ra --layer epi --fibre l --msh RA_only_RAA --scalar-file Extra_CT.dat --output MappedScalar_CT
python $PROJECT/docker/entrypoint.py scalarmap --atrium ra --layer epi --fibre l --msh RA_only_RAA --scalar-file Extra_PM.dat --output MappedScalar_PM


echo "======Fibre mapping bilayer for LA======"
python $PROJECT/docker/entrypoint.py fibremap --atrium la --layer bilayer --fibre l --fourch --msh LA_only --msh-endo Labelled --msh-epi Labelled --output Fibre_Labarthe_Bilayer --code-dir $PROJECT --base-dir "$laepi_dir/"

echo "Fibre mapping bilayer for RA"
python $PROJECT/docker/entrypoint.py fibremap --atrium ra --layer bilayer --fibre l --fourch --msh RA_only_RAA --msh-endo Labelled --msh-epi Labelled --output Fibre_Labarthe_Bilayer --code-dir $PROJECT --base-dir "$raepi_dir/"

# # ## remove RA endocardial shell
# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer -tags=1,2,3,8,9 -submsh=$DATA/RA_epi/Bilayer2 -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/Bilayer2.vtk -omsh=$DATA/RA_epi/Bilayer2 -ofmt=carp_txt


# ## combine LA & RA & add RA elements
# meshtool extract mesh -msh=$DATA/LA_epi/Bilayer -tags=11,12 -submsh=$DATA/LA_epi/Bilayer2 -ofmt=vtk
# meshtool convert -imsh=$DATA/LA_epi/Bilayer2.vtk -omsh=$DATA/LA_epi/Bilayer2 -ofmt=carp_txt

# meshtool merge meshes -msh1=$DATA/LA_epi/Bilayer2 -msh2=$DATA/RA_epi/Bilayer2 -ofmt=carp_txt -outmsh=$DATA/RA_epi/Bilayer_Combined


# ## add IAC

# cp "$DATA/LA_epi/LA_only.pts" "$DATA/LA_epi/Labelled.pts"
# cp "$DATA/LA_epi/LA_only.elem" "$DATA/LA_epi/Labelled.elem"
# cp "$DATA/LA_epi/LA_only.lon" "$DATA/LA_epi/Labelled.lon"

# cp "$DATA/RA_epi/RA_only_RAA.pts" "$DATA/RA_epi/Labelled.pts"
# cp "$DATA/RA_epi/RA_only_RAA.elem" "$DATA/RA_epi/Labelled.elem"
# cp "$DATA/RA_epi/RA_only_RAA.lon" "$DATA/RA_epi/Labelled.lon"

# python $PROJECT/uac/lat_field_biatrial_bilayer_meshtool.py "$DATA/LA_epi/" "$DATA/RA_epi/" LAT_Spiral4_B.dat Labelled Bilayer_Combined


# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=11 -submsh=$DATA/RA_epi/LA_endo -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/LA_endo.vtk -omsh=$DATA/RA_epi/LA_endo -ofmt=carp_txt

# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=12 -submsh=$DATA/RA_epi/LA_epi -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/LA_epi.vtk -omsh=$DATA/RA_epi/LA_epi -ofmt=carp_txt

# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=1,2 -submsh=$DATA/RA_epi/RA_epi_s -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/RA_epi_s.vtk -omsh=$DATA/RA_epi/RA_epi_s -ofmt=carp_txt

# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=3,8,9 -submsh=$DATA/RA_epi/RA_structures -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/RA_structures.vtk -omsh=$DATA/RA_epi/RA_structures  -ofmt=carp_txt


# #make bilayer mesh with lines & visualisation
# python $PROJECT/uac/biatrial_bilayer_lines_visualisation.py "$DATA/RA_epi/" Bilayer_Combined Fibre_Labarthe_Bilayer;

echo "finished"