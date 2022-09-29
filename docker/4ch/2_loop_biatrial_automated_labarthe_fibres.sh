#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  PROJECT'
    >&2 echo '  DATA'
    exit 1
fi
PROJECT="$1"
DATA="$2"

cp "$DATA/Landmarks/LA/prodRaLandmarks.txt" "$DATA/LA_endo/Landmarks.txt"
cp "$DATA/Landmarks/LA/prodRaRegion.txt" "$DATA/LA_endo/Regions.txt"

docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_A"

docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LS"
docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PA"

docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LAA"

meshtool convert -imsh=$DATA/LA_endo/LA_endo.vtk -omsh=$DATA/LA_endo/LA_only -ofmt=carp_txt -scale=1000

echo "=====Old UAC approximation====="
# python $PROJECT/uac/1_la_4ch.py "$DATA/LA_endo/" LA_only Landmarks.txt Regions.txt 1000
docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha uac --uac-stage 1 --atrium la --layer endo --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000

docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2


echo "=====New UAC====="
# python $PROJECT/uac/2a_la_4ch.py "$DATA/LA_endo/" LA_only Landmarks.txt Regions.txt 1000
docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha uac --uac-stage 2a --atrium la --layer endo --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000


docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
# python $PROJECT/uac/2b_la.py "$DATA/LA_endo/" "$PROJECT/fibre_files/la/endo/" "$PROJECT/laplace_files/" LA_only 11 13 21 23 25 27 1
docker run --rm --volume="$DATA/LA_endo":/data cemrg/uac:3.0-alpha uac --uac-stage 2b --atrium la --layer endo --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000




echo "repeat this for epi!"
cp "$DATA/Landmarks/LA/prodRaLandmarks.txt" "$DATA/LA_epi/Landmarks.txt"
cp "$DATA/Landmarks/LA/prodRaRegion.txt" "$DATA/LA_epi/Regions.txt"


docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_A"

docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LS"
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PA"

docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LAA"

meshtool convert -imsh=$DATA/LA_epi/LA_epi.vtk -omsh=$DATA/LA_epi/LA_only -ofmt=carp_txt -scale=1000

## Old UAC approximation
# python $PROJECT/uac/1_la_4ch.py "$DATA/LA_epi/" LA_only Landmarks.txt Regions.txt 1000
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha uac --uac-stage 1 --atrium la --layer epi --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000


docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2


echo "=====New UAC====="
# python $PROJECT/uac/2a_la_4ch.py "$DATA/LA_epi/" LA_only Landmarks.txt Regions.txt 1000
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha uac --uac-stage 2a --atrium la --layer epi --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000


docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
# python $PROJECT/uac/2b_la.py "$DATA/LA_epi/" "$PROJECT/fibre_files/la/endo/" "$PROJECT/laplace_files/" LA_only 11 13 21 23 25 27 1
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha uac --uac-stage 2b --atrium la --layer epi --fourch --msh LA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000


echo "=====Add fibres2 ====="
# python $PROJECT/uac/fibre_mapping.py "$DATA/LA_epi/" "$PROJECT/fibre_files/la/endo/l/" "$PROJECT/laplace_files/" LA_only Labelled.lon Fibre_Labarthe
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha fibremap --atrium la --layer endo --fibre l --msh LA_only --msh-endo Labelled --msh-epi Labelled --output Fibre_Labarthe 


echo "=====Add LAT field ($i)====="
# python $PROJECT/uac/lat_field.py "$DATA/LA_epi/" LAT_Spiral4_B.dat Fibre_L
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha latfield --lat-type normal --lat-file LAT_Spiral4_B.dat --msh Fibre_L


#repeat this for RA epi!


cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$DATA/RA_epi/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$DATA/RA_epi/Regions.txt"

docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_A"

docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LS"
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PA"

docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LAA"
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_RAA"

meshtool convert -imsh=$DATA/RA_epi/RA_epi.vtk -omsh=$DATA/RA_epi/RA_only -ofmt=carp_txt -scale=1000

# NEED TO SPLIT AS BEFORE & AFTER CARP
# python $PROJECT/uac/labels_landmarks_ra.py "$DATA/RA_epi/" RA_only Landmarks.txt Regions.txt 0.6 1000
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha --labels-lndmrks --labels-stage 1 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 


docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA


# python $PROJECT/uac/labels_landmarks_ra_2.py "$DATA/RA_epi/" RA_only Landmarks.txt Regions.txt 0.6 1000
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha --labels-lndmrks --labels-stage 2 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 


## Old UAC approximation
# python $PROJECT/uac/1_ra_4ch.py "$DATA/RA_epi/" RA_only_RAA Landmarks.txt Regions.txt 1000
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha uac --uac-stage 1 --atrium ra --layer epi --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000


docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2


echo "=====New UAC====="
# python $PROJECT/uac/2a_ra_4ch.py "$DATA/RA_epi/" RA_only_RAA Landmarks.txt Regions.txt 1000
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha uac --uac-stage 2a --atrium ra --layer epi --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000

docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
# python $PROJECT/uac/2b_ra.py "$DATA/RA_epi/" RA_only_RAA 1 6 7 5 2 1
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha uac --uac-stage 2b --atrium ra --layer epi --fourch --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1


cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$DATA/RA_endo/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$DATA/RA_endo/Regions.txt"

docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_A"

docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LS"
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_PA"

docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_LAA"
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_RAA"

meshtool convert -imsh=$DATA/RA_endo/RA_endo.vtk -omsh=$DATA/RA_endo/RA_only -ofmt=carp_txt -scale=1000


# NEED TO SPLIT AS BEFORE & AFTER CARP
# python $PROJECT/uac/labels_landmarks_ra.py "$DATA/RA_endo/" RA_only Landmarks.txt Regions.txt 0.6 1000
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha labels --labels-lndmrks --labels-stage 1 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 


docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA


# python $PROJECT/uac/labels_landmarks_ra_2.py "$DATA/RA_endo/" RA_only Landmarks.txt Regions.txt 0.6 1000
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha labels --labels-lndmrks --labels-stage 2 --labels-thresh 0.6 --msh RA_only --landmarks Landmarks.txt --regions Regions.txt --scale 1000 


## Old UAC approximation
# python $PROJECT/uac/1_ra_4ch.py "$DATA/RA_endo/" RA_only_RAA Landmarks.txt Regions.txt 1000
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha uac --uac-stage 1 --atrium ra --fourch --layer endo --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000



docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2



echo "=====New UAC====="
# python $PROJECT/uac/2a_ra_4ch.py "$DATA/RA_endo/" RA_only_RAA Landmarks.txt Regions.txt 1000
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha uac --uac-stage 2a --atrium ra --fourch --layer endo --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000

docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
# python $PROJECT/uac/2b_ra.py "$DATA/RA_endo/" RA_only_RAA 1 6 7 5 2 1
docker run --rm --volume="$DATA/RA_endo":/data cemrg/uac:3.0-alpha uac --uac-stage 2b --atrium ra --fourch --layer endo --msh RA_only_RAA --landmarks Landmarks.txt --regions Regions.txt --scale 1000

#Fibres next

echo "=====Add fibres2 ====="
# python $PROJECT/uac/fibre_mapping.py "$DATA/RA_epi/" "$PROJECT/fibre_files/ra/epi/l/" "$PROJECT/laplace_files/" RA_only_RAA Labelled.lon Fibre_Labarthe
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha fibremap --atrium ra --layer epi --fibre l --msh RA_only_RAA --msh-endo Labelled --output Fibre_Labarthe


echo "=====Add LAT field ($i)====="
# python $PROJECT/uac/lat_field.py "$DATA/RA_epi/" LAT_Spiral4_B.dat Fibre_Labarthe 
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha latfield --lat-type normal --lat-file LAT_Spiral4_B.dat --output Fibre_Labarthe 



# python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/RA_epi/" "$PROJECT/extra_structures/" RA_only_RAA Extra_SAN.dat MappedScalar_SAN.dat
docker run --rm --volume= "$DATA/RA_epi":/data cemrg/uac:3.0-alpha scalarmap --msh RA_only_RAA --scalar-file Extra_SAN.dat --output MappedScalar_SAN.dat
# python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/RA_epi/" "$PROJECT/extra_structures/" RA_only_RAA Extra_CT.dat MappedScalar_CT.dat
docker run --rm --volume= "$DATA/RA_epi":/data cemrg/uac:3.0-alpha scalarmap --msh RA_only_RAA --scalar-file Extra_CT.dat --output MappedScalar_CT.dat  
# python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/RA_epi/" "$PROJECT/extra_structures/" RA_only_RAA Extra_PM.dat MappedScalar_PM.dat
docker run --rm --volume= "$DATA/RA_epi":/data cemrg/uac:3.0-alpha scalarmap --msh RA_only_RAA --scalar-file Extra_PM.dat --output MappedScalar_PM.dat  


###Fibre mapping bilayer for LA
# python $PROJECT/uac/fibre_mapping_bilayer_4ch.py "$DATA/LA_epi/" "$PROJECT/fibre_files/la/endo/l/" "$PROJECT/fibre_files/la/epi/l/" "$PROJECT/laplace_files/" Labelled Labelled LA_only Labelled.lon Labelled.lon Fibre_Labarthe_Bilayer
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha fibremap --atrium la --layer bilayer --fibre l --msh-endo Labelled --msh-epi Labelled --msh LA_only --output Fibre_Labarthe_Bilayer


##Fibre mapping bilayer for RA
# python $PROJECT/uac/fibre_mapping_bilayer_ra_4ch.py "$DATA/RA_epi/" "$PROJECT/fibre_files/ra/epi/l/" "$PROJECT/fibre_files/ra/endo/l/" "$PROJECT/laplace_files/" Labelled Labelled RA_only_RAA Labelled.lon Labelled.lon Fibre_Labarthe_Bilayer
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha fibremap --atrium ra --layer bilayer --fibre l --msh-endo Labelled --msh-epi Labelled --msh RA_only_RAA --output Fibre_Labarthe_Bilayer 


## remove RA endocardial shell
meshtool extract mesh -msh=$DATA/RA_epi/Bilayer -tags=1,2,3,8,9 -submsh=$DATA/RA_epi/Bilayer2 -ofmt=vtk
meshtool convert -imsh=$DATA/RA_epi/Bilayer2.vtk -omsh=$DATA/RA_epi/Bilayer2 -ofmt=carp_txt


## combine LA & RA & add RA elements
meshtool extract mesh -msh=$DATA/LA_epi/Bilayer -tags=11,12 -submsh=$DATA/LA_epi/Bilayer2 -ofmt=vtk
meshtool convert -imsh=$DATA/LA_epi/Bilayer2.vtk -omsh=$DATA/LA_epi/Bilayer2 -ofmt=carp_txt

meshtool merge meshes -msh1=$DATA/LA_epi/Bilayer2 -msh2=$DATA/RA_epi/Bilayer2 -ofmt=carp_txt -outmsh=$DATA/RA_epi/Bilayer_Combined


## add IAC

cp "$DATA/LA_epi/LA_only.pts" "$DATA/LA_epi/Labelled.pts"
cp "$DATA/LA_epi/LA_only.elem" "$DATA/LA_epi/Labelled.elem"
cp "$DATA/LA_epi/LA_only.lon" "$DATA/LA_epi/Labelled.lon"

cp "$DATA/RA_epi/RA_only_RAA.pts" "$DATA/RA_epi/Labelled.pts"
cp "$DATA/RA_epi/RA_only_RAA.elem" "$DATA/RA_epi/Labelled.elem"
cp "$DATA/RA_epi/RA_only_RAA.lon" "$DATA/RA_epi/Labelled.lon"

# python $PROJECT/uac/lat_field_biatrial_bilayer_meshtool.py "$DATA/LA_epi/" "$DATA/RA_epi/" LAT_Spiral4_B.dat Labelled Bilayer_Combined
docker run --rm --volume="$DATA/LA_epi":/data cemrg/uac:3.0-alpha latfield --lat-type meshtool --lat-base-dir-ra ../RA_epi --lat-file LAT_Spiral4_B.dat --lat-msh-biatrial Labelled --output Bilayer_Combined --debug


# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=11 -submsh=$DATA/RA_epi/LA_endo -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/LA_endo.vtk -omsh=$DATA/RA_epi/LA_endo -ofmt=carp_txt

# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=12 -submsh=$DATA/RA_epi/LA_epi -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/LA_epi.vtk -omsh=$DATA/RA_epi/LA_epi -ofmt=carp_txt

# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=1,2 -submsh=$DATA/RA_epi/RA_epi_s -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/RA_epi_s.vtk -omsh=$DATA/RA_epi/RA_epi_s -ofmt=carp_txt

# meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=3,8,9 -submsh=$DATA/RA_epi/RA_structures -ofmt=vtk
# meshtool convert -imsh=$DATA/RA_epi/RA_structures.vtk -omsh=$DATA/RA_epi/RA_structures  -ofmt=carp_txt


#make bilayer mesh with lines & visualisation
# python $PROJECT/uac/biatrial_bilayer_lines_visualisation.py "$DATA/RA_epi/" Bilayer_Combined Fibre_Labarthe_Bilayer;
docker run --rm --volume="$DATA/RA_epi":/data cemrg/uac:3.0-alpha vis # not supported yet 
