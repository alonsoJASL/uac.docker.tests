#!/bin/bash

PROJECT="$HOME/uac-refact"
DATA="$HOME/tests-refact/4ch"


cp "$DATA/Landmarks/LA/prodRaLandmarks.txt" "$DATA/LA_endo/Landmarks.txt"
cp "$DATA/Landmarks/LA/prodRaRegion.txt" "$DATA/LA_endo/Regions.txt"

cp "$PROJECT/laplace_files/carpf_laplace_single_LR_P.par" "$DATA/LA_endo/carpf_laplace_single_LR_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_P.par" "$DATA/LA_endo/carpf_laplace_single_UD_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_LR_A.par" "$DATA/LA_endo/carpf_laplace_single_LR_A.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_A.par" "$DATA/LA_endo/carpf_laplace_single_UD_A.par"

cp "$PROJECT/laplace_files/carpf_laplace_LS_4Ch.par" "$DATA/LA_endo/carpf_laplace_LS.par"
cp "$PROJECT/laplace_files/carpf_laplace_PA_4Ch.par" "$DATA/LA_endo/carpf_laplace_PA.par"

cp "$PROJECT/laplace_files/carpf_laplace_LAA_4Ch.par" "$DATA/LA_endo/carpf_laplace_LAA.par"


meshtool convert -imsh=$DATA/LA_endo/LA_endo.vtk -omsh=$DATA/LA_endo/LA_only -ofmt=carp_txt -scale=1000



## Old UAC approximation
python $PROJECT/uac/1_la_4ch.py "$DATA/LA_endo/" LA_only Landmarks.txt Regions.txt 1000


docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2


echo "=====New UAC====="
python $PROJECT/uac/2a_la_4ch.py "$DATA/LA_endo/" LA_only Landmarks.txt Regions.txt 1000


docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA/LA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
python $PROJECT/uac/2b_la.py "$DATA/LA_endo/" "$PROJECT/fibre_files/la/endo/" "$PROJECT/laplace_files/" LA_only 11 13 21 23 25 27 1



cp "$DATA/Landmarks/LA/prodRaLandmarks.txt" "$DATA/LA_epi/Landmarks.txt"
cp "$DATA/Landmarks/LA/prodRaRegion.txt" "$DATA/LA_epi/Regions.txt"


#repeat this for epi!


cp "$PROJECT/laplace_files/carpf_laplace_single_LR_P.par" "$DATA/LA_epi/carpf_laplace_single_LR_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_P.par" "$DATA/LA_epi/carpf_laplace_single_UD_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_LR_A.par" "$DATA/LA_epi/carpf_laplace_single_LR_A.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_A.par" "$DATA/LA_epi/carpf_laplace_single_UD_A.par"

cp "$PROJECT/laplace_files/carpf_laplace_LS_4Ch.par" "$DATA/LA_epi/carpf_laplace_LS.par"
cp "$PROJECT/laplace_files/carpf_laplace_PA_4Ch.par" "$DATA/LA_epi/carpf_laplace_PA.par"

cp "$PROJECT/laplace_files/carpf_laplace_LAA_4Ch.par" "$DATA/LA_epi/carpf_laplace_LAA.par"

meshtool convert -imsh=$DATA/LA_epi/LA_epi.vtk -omsh=$DATA/LA_epi/LA_only -ofmt=carp_txt -scale=1000

## Old UAC approximation
python $PROJECT/uac/1_la_4ch.py "$DATA/LA_epi/" LA_only Landmarks.txt Regions.txt 1000


docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2


echo "=====New UAC====="
python $PROJECT/uac/2a_la_4ch.py "$DATA/LA_epi/" LA_only Landmarks.txt Regions.txt 1000


docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA/LA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
python $PROJECT/uac/2b_la.py "$DATA/LA_epi/" "$PROJECT/fibre_files/la/endo/" "$PROJECT/laplace_files/" LA_only 11 13 21 23 25 27 1


echo "=====Add fibres2 ====="
python $PROJECT/uac/fibre_mapping.py "$DATA/LA_epi/" "$PROJECT/fibre_files/la/endo/l/" "$PROJECT/laplace_files/" LA_only Labelled.lon Fibre_Labarthe


echo "=====Add LAT field ($i)====="
python $PROJECT/uac/lat_field.py "$DATA/LA_epi/" LAT_Spiral4_B.dat Fibre_L


#repeat this for RA epi!


cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$DATA/RA_epi/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$DATA/RA_epi/Regions.txt"

cp "$PROJECT/laplace_files/carpf_laplace_single_LR_P.par" "$DATA/RA_epi/carpf_laplace_single_LR_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_P.par" "$DATA/RA_epi/carpf_laplace_single_UD_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_LR_A.par" "$DATA/RA_epi/carpf_laplace_single_LR_A.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_A.par" "$DATA/RA_epi/carpf_laplace_single_UD_A.par"

cp "$PROJECT/laplace_files/carpf_laplace_LS_4Ch_RA.par" "$DATA/RA_epi/carpf_laplace_LS.par"
cp "$PROJECT/laplace_files/carpf_laplace_PA_4Ch_RA.par" "$DATA/RA_epi/carpf_laplace_PA.par"

cp "$PROJECT/laplace_files/carpf_laplace_LAA_4Ch.par" "$DATA/RA_epi/carpf_laplace_LAA.par"
cp "$PROJECT/laplace_files/carpf_laplace_RAA.par" "$DATA/RA_epi/carpf_laplace_RAA.par"

meshtool convert -imsh=$DATA/RA_epi/RA_epi.vtk -omsh=$DATA/RA_epi/RA_only -ofmt=carp_txt -scale=1000

# NEED TO SPLIT AS BEFORE & AFTER CARP
python $PROJECT/uac/labels_landmarks_ra.py "$DATA/RA_epi/" RA_only Landmarks.txt Regions.txt 0.6 1000


docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA


python $PROJECT/uac/labels_landmarks_ra_2.py "$DATA/RA_epi/" RA_only Landmarks.txt Regions.txt 0.6 1000


## Old UAC approximation
python $PROJECT/uac/1_ra_4ch.py "$DATA/RA_epi/" RA_only_RAA Landmarks.txt Regions.txt 1000


docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2


echo "=====New UAC====="
python $PROJECT/uac/2a_ra_4ch.py "$DATA/RA_epi/" RA_only_RAA Landmarks.txt Regions.txt 1000


docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA/RA_epi":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
python $PROJECT/uac/2b_ra.py "$DATA/RA_epi/" RA_only_RAA 1 6 7 5 2 1


cp "$DATA/Landmarks/RA/prodRaLandmarks.txt" "$DATA/RA_endo/Landmarks.txt"
cp "$DATA/Landmarks/RA/prodRaRegion.txt" "$DATA/RA_endo/Regions.txt"

cp "$PROJECT/laplace_files/carpf_laplace_single_LR_P.par" "$DATA/RA_endo/carpf_laplace_single_LR_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_P.par" "$DATA/RA_endo/carpf_laplace_single_UD_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_LR_A.par" "$DATA/RA_endo/carpf_laplace_single_LR_A.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_A.par" "$DATA/RA_endo/carpf_laplace_single_UD_A.par"

cp "$PROJECT/laplace_files/carpf_laplace_LS_4Ch_RA.par" "$DATA/RA_endo/carpf_laplace_LS.par"
cp "$PROJECT/laplace_files/carpf_laplace_PA_4Ch_RA.par" "$DATA/RA_endo/carpf_laplace_PA.par"

cp "$PROJECT/laplace_files/carpf_laplace_LAA_4Ch.par" "$DATA/RA_endo/carpf_laplace_LAA.par"
cp "$PROJECT/laplace_files/carpf_laplace_RAA.par" "$DATA/RA_endo/carpf_laplace_RAA.par"

meshtool convert -imsh=$DATA/RA_endo/RA_endo.vtk -omsh=$DATA/RA_endo/RA_only -ofmt=carp_txt -scale=1000


# NEED TO SPLIT AS BEFORE & AFTER CARP
python $PROJECT/uac/labels_landmarks_ra.py "$DATA/RA_endo/" RA_only Landmarks.txt Regions.txt 0.6 1000


docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_RAA.par -simID MV_LAA


python $PROJECT/uac/labels_landmarks_ra_2.py "$DATA/RA_endo/" RA_only Landmarks.txt Regions.txt 0.6 1000


## Old UAC approximation
python $PROJECT/uac/1_ra_4ch.py "$DATA/RA_endo/" RA_only_RAA Landmarks.txt Regions.txt 1000



docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2



echo "=====New UAC====="
python $PROJECT/uac/2a_ra_4ch.py "$DATA/RA_endo/" RA_only_RAA Landmarks.txt Regions.txt 1000


docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA/RA_endo":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC


echo "=====New UAC part 2====="
python $PROJECT/uac/2b_ra.py "$DATA/RA_endo/" RA_only_RAA 1 6 7 5 2 1


#Fibres next

echo "=====Add fibres2 ====="
python $PROJECT/uac/fibre_mapping.py "$DATA/RA_epi/" "$PROJECT/fibre_files/ra/epi/l/" "$PROJECT/laplace_files/" RA_only_RAA Labelled.lon Fibre_Labarthe


echo "=====Add LAT field ($i)====="
python $PROJECT/uac/lat_field.py "$DATA/RA_epi/" LAT_Spiral4_B.dat Fibre_Labarthe



python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/RA_epi/" "$PROJECT/extra_structures/" RA_only_RAA Extra_SAN.dat MappedScalar_SAN.dat
python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/RA_epi/" "$PROJECT/extra_structures/" RA_only_RAA Extra_CT.dat MappedScalar_CT.dat
python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/RA_epi/" "$PROJECT/extra_structures/" RA_only_RAA Extra_PM.dat MappedScalar_PM.dat


###Fibre mapping bilayer for LA
python $PROJECT/uac/fibre_mapping_bilayer_4ch.py "$DATA/LA_epi/" "$PROJECT/fibre_files/la/endo/l/" "$PROJECT/fibre_files/la/epi/l/" "$PROJECT/laplace_files/" Labelled Labelled LA_only Labelled.lon Labelled.lon Fibre_Labarthe_Bilayer


##Fibre mapping bilayer for RA
python $PROJECT/uac/fibre_mapping_bilayer_ra_4ch.py "$DATA/RA_epi/" "$PROJECT/fibre_files/ra/epi/l/" "$PROJECT/fibre_files/ra/endo/l/" "$PROJECT/laplace_files/" Labelled Labelled RA_only_RAA Labelled.lon Labelled.lon Fibre_Labarthe_Bilayer


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

python $PROJECT/uac/lat_field_biatrial_bilayer_meshtool.py "$DATA/LA_epi/" "$DATA/RA_epi/" LAT_Spiral4_B.dat Labelled Bilayer_Combined


meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=11 -submsh=$DATA/RA_epi/LA_endo -ofmt=vtk
meshtool convert -imsh=$DATA/RA_epi/LA_endo.vtk -omsh=$DATA/RA_epi/LA_endo -ofmt=carp_txt

meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=12 -submsh=$DATA/RA_epi/LA_epi -ofmt=vtk
meshtool convert -imsh=$DATA/RA_epi/LA_epi.vtk -omsh=$DATA/RA_epi/LA_epi -ofmt=carp_txt

meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=1,2 -submsh=$DATA/RA_epi/RA_epi_s -ofmt=vtk
meshtool convert -imsh=$DATA/RA_epi/RA_epi_s.vtk -omsh=$DATA/RA_epi/RA_epi_s -ofmt=carp_txt

meshtool extract mesh -msh=$DATA/RA_epi/Bilayer_Combined -tags=3,8,9 -submsh=$DATA/RA_epi/RA_structures -ofmt=vtk
meshtool convert -imsh=$DATA/RA_epi/RA_structures.vtk -omsh=$DATA/RA_epi/RA_structures  -ofmt=carp_txt


#make bilayer mesh with lines & visualisation
python $PROJECT/uac/biatrial_bilayer_lines_visualisation.py "$DATA/RA_epi/" Bilayer_Combined Fibre_Labarthe_Bilayer;
