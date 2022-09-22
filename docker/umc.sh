#!/bin/bash

for i in {5..5}
do

PROJECT="$1"
#DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/LA_UAC"

'''


#assumes have run CemrgApp for LA UAC.

cp "$PROJECT/laplace_files/carpf_laplace_LS.par" "$DATA/carpf_laplace_LS.par"
cp "$PROJECT/laplace_files/carpf_laplace_PA.par" "$DATA/carpf_laplace_PA.par"
python $PROJECT/uac/$PROJECT/uac/1_la.py "$DATA/" "$PROJECT/fibre_files/la/endo/" "$PROJECT/laplace_files/" Labelled 11 13 21 23 25 27 Landmarks.txt 1000


clear
echo "=====Old UAC approximation - openCARP command line ($i)====="
openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2

clear
echo "=====New UAC====="
cp "$PROJECT/laplace_files/carpf_laplace_single_LR_P.par" "$DATA/carpf_laplace_single_LR_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_P.par" "$DATA/carpf_laplace_single_UD_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_LR_A.par" "$DATA/carpf_laplace_single_LR_A.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_A.par" "$DATA/carpf_laplace_single_UD_A.par"
python $PROJECT/uac/2a_la.py "$DATA/" "$PROJECT/fibre_files/la/endo/" "$PROJECT/laplace_files/" Labelled 11 13 21 23 25 27 Landmarks.txt 1000

openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC

clear
echo "=====New UAC part 2====="
python $PROJECT/uac/2b_la.py "$DATA/" "$PROJECT/fibre_files/la/endo/" "$PROJECT/laplace_files/" Labelled 11 13 21 23 25 27 1000


echo "=====Add fibres2 ====="
python $PROJECT/uac/fibre_mapping.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled Labelled.lon Fibre_$i


clear
echo "=====Add LAT field ($i)====="
python $PROJECT/uac/lat_field.py "$DATA/" LAT_Spiral4_B.dat Fibre_$i

clear
echo "=====Make PV stimulus files .vtx ($i)====="
python $PROJECT/uac/lspv_nodes.py "$DATA/" Labelled 11 13 21 23 25 27

#RA next. Open segmentation nii in CemrgApp, create a surface by PV button. Open segmentation.vtk in paraview. Clip it and save as Clipped.vtk. Open Clipped.vtk in paraview, select landmarks. Save as a carp file Labelled_n

meshtool resample surfmesh -msh=/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC/Labelled_$i -avrg=300 -outmsh=/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC/Labelled -surf_corr=0.95

meshtool clean topology -msh=/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC/Labelled -outmsh=/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC/Labelled

meshtool clean quality -msh=/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC/Labelled -thr=0.95 -outmsh=/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC/Labelled


DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC"


python $PROJECT/uac/labels_ra_1.py "$DATA/" "$PROJECT/fibre_files/ra/endo/" "$PROJECT/laplace_files/" Labelled 0.8 0.5 prodRaRegion.txt 1000


cp "$PROJECT/laplace_files/carpf_laplace_PV2.par" "$DATA/carpf_laplace_PV2.par"
cp "$PROJECT/laplace_files/carpf_laplace_PV3.par" "$DATA/carpf_laplace_PV3.par"
cp "$PROJECT/laplace_files/carpf_laplace_PV4.par" "$DATA/carpf_laplace_PV4.par"
cp "$PROJECT/laplace_files/carpf_laplace_LAA.par" "$DATA/carpf_laplace_LAA.par"


openCARP +F carpf_laplace_PV2.par -simID MV_PV2
openCARP +F carpf_laplace_PV3.par -simID MV_PV3
openCARP +F carpf_laplace_PV4.par -simID MV_PV4
openCARP +F carpf_laplace_LAA.par -simID MV_LAA

python $PROJECT/uac/labels_ra_2.py "$DATA/" "$PROJECT/fibre_files/ra/endo/" "$PROJECT/laplace_files/" Labelled 0.8 0.5 prodRaRegion.txt 1000



cp "$DATA/Labelled_Labels.elem" "$DATA/Labelled.elem"

MeshName="Labelled"
Landmarks="prodRaLandmarks.txt"
Region="prodRaRegion.txt"


clear
echo "=====Old UAC approximation ====="
cp "$PROJECT/laplace_files/carpf_laplace_LS.par" "$DATA/carpf_laplace_LS.par"
cp "$PROJECT/laplace_files/carpf_laplace_PA.par" "$DATA/carpf_laplace_PA.par"
python $PROJECT/uac/1_ra.py "$DATA/" "$PROJECT/fibre_files/ra/endo/" "$PROJECT/laplace_files/" $MeshName 1 6 7 5 2 $Landmarks $Region 1000


clear
echo "=====Old UAC approximation - openCARP command line ($i)====="
openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2

clear
echo "=====New UAC====="
cp "$PROJECT/laplace_files/carpf_laplace_single_LR_P.par" "$DATA/carpf_laplace_single_LR_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_P.par" "$DATA/carpf_laplace_single_UD_P.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_LR_A.par" "$DATA/carpf_laplace_single_LR_A.par"
cp "$PROJECT/laplace_files/carpf_laplace_single_UD_A.par" "$DATA/carpf_laplace_single_UD_A.par"
python $PROJECT/uac/2a_ra.py "$DATA/" "$PROJECT/fibre_files/ra/endo/" "$PROJECT/laplace_files/" $MeshName 1 6 7 5 2 $Landmarks $Region 1000

openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC



DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC"
#clear
MeshName="Labelled"
echo "=====New UAC part 2====="
python $PROJECT/uac/2b_ra.py "$DATA/" $MeshName 1 6 7 5 2 1



#Fibres next
DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC"


echo "=====Add fibres2 ====="
python $PROJECT/uac/fibre_mapping.py "$DATA/" "$PROJECT/fibre_files/ra/epi/$i/" "$PROJECT/laplace_files/" Labelled Labelled.lon Fibre_$i


clear
echo "=====Add LAT field ($i)====="
python $PROJECT/uac/lat_field.py "$DATA/" LAT_Spiral4_B.dat Fibre_$i



python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/" "$PROJECT/extra_structures/" Labelled Extra_SAN.dat MappedScalar_SAN.dat

python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/" "$PROJECT/extra_structures/" Labelled Extra_CT.dat MappedScalar_CT.dat

python $PROJECT/uac/scalar_mapping_bilayer.py  "$DATA/" "$PROJECT/extra_structures/" Labelled Extra_PM.dat MappedScalar_PM.dat

DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/LA_UAC"
###Fibre mapping bilayer for LA
python $PROJECT/uac/fibre_mapping_bilayer.py "$DATA/" "$PROJECT/fibre_files/la/endo/l/" "$PROJECT/fibre_files/la/epi/l/" "$PROJECT/laplace_files/" Labelled Labelled.lon Labelled.lon Fibre_Bilayer_L


'''

DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/RA_UAC"
##Fibre mapping bilayer for RA
python $PROJECT/uac/fibre_mapping_bilayer_ra.py "$DATA/" "$PROJECT/fibre_files/ra/epi/l/" "$PROJECT/fibre_files/ra/endo/l/" Labelled Labelled Labelled Labelled.lon Labelled.lon Fibre_Labarthe_Bilayer



DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/"
cd $DATA/

## remove RA endocardial shell
meshtool extract mesh -msh=$DATA/RA_UAC/Bilayer -tags=1,2,3,5,6,7,8,9 -submsh=$DATA/RA_UAC/Bilayer2 -ofmt=vtk
meshtool convert -imsh=$DATA/RA_UAC/Bilayer2.vtk -omsh=$DATA/RA_UAC/Bilayer2 -ofmt=carp_txt

## combine LA & RA & add RA elements
meshtool extract mesh -msh=$DATA/LA_UAC/Bilayer -tags=11,12,13,14,21,22,23,24,25,26,27,28 -submsh=$DATA/LA_UAC/Bilayer2 -ofmt=vtk
meshtool convert -imsh=$DATA/LA_UAC/Bilayer2.vtk -omsh=$DATA/LA_UAC/Bilayer2 -ofmt=carp_txt

#clear
meshtool merge meshes -msh1=$DATA/LA_UAC/Bilayer2 -msh2=$DATA/RA_UAC/Bilayer2 -ofmt=carp_txt -outmsh=$DATA/RA_UAC/Bilayer_Combined

## add IAC
DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/"


python $PROJECT/uac/lat_field_biatrial_bilayer_meshtool.py "$DATA/LA_UAC/" "$DATA/RA_UAC/" LAT_Spiral4_B.dat Labelled Bilayer_Combined


meshtool extract mesh -msh=$DATA/RA_UAC/Bilayer_Combined -tags=11,13,21,23,25,27 -submsh=$DATA/RA_UAC/LA_endo -ofmt=vtk
meshtool convert -imsh=$DATA/RA_UAC/LA_endo.vtk -omsh=$DATA/RA_UAC/LA_endo -ofmt=carp_txt

meshtool extract mesh -msh=$DATA/RA_UAC/Bilayer_Combined -tags=12,14,22,24,26,28 -submsh=$DATA/RA_UAC/LA_epi -ofmt=vtk
meshtool convert -imsh=$DATA/RA_UAC/LA_epi.vtk -omsh=$DATA/RA_UAC/LA_epi -ofmt=carp_txt

meshtool extract mesh -msh=$DATA/RA_UAC/Bilayer_Combined -tags=1,2,5,6,7 -submsh=$DATA/RA_UAC/RA_epi_s -ofmt=vtk
meshtool convert -imsh=$DATA/RA_UAC/RA_epi_s.vtk -omsh=$DATA/RA_UAC/RA_epi_s -ofmt=carp_txt

meshtool extract mesh -msh=$DATA/RA_UAC/Bilayer_Combined -tags=3,8,9 -submsh=$DATA/RA_UAC/RA_structures -ofmt=vtk
meshtool convert -imsh=$DATA/RA_UAC/RA_structures.vtk -omsh=$DATA/RA_UAC/RA_structures  -ofmt=carp_txt



#make bilayer mesh with lines & visualisation
DATA="/media/caroline/Caro_2022/Final2/Scans_KCL_Simulations-2/$i/"
python $PROJECT/uac/biatrial_bilayer_lines_visualisation.py "$DATA/RA_UAC/" Bilayer_Combined Fibre_Labarthe_Bilayer;


done
