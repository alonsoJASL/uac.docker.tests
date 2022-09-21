#!/bin/bash

for i in {1..7}
do

PROJECT="$HOME/uac-refact"
DATA="$HOME/tests-refact/la/epi/$i"

echo "=====Add fibres 2====="
python $PROJECT/uac/fibre_mapping.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/laplace_files/" Labelled Labelled.lon Fibres

echo "=====Add fibres 2 Bilayer====="
python $PROJECT/uac/fibre_mapping_bilayer.py "$DATA/" "$PROJECT/fibre_files/la/endo/$i/" "$PROJECT/fibre_files/la/epi/$i/" "$PROJECT/laplace_files/" Labelled Labelled.lon Labelled.lon Fibre_Bilayer

echo "=====Add LAT field ($i)====="
python $PROJECT/uac/lat_field.py "$DATA/" LAT_Spiral4_B.dat Fibres

echo "=====Make PV stimulus files .vtx ($i)====="
python $PROJECT/uac/lspv_nodes.py "$DATA/" Labelled 11 13 21 23 25 27

# mkdir $DATA/Sim
# cp "$PROJECT/SimulationFiles/AF_100.par" "$DATA/Sim/AF.par"
# cp "$DATA/Fibres.pts" "$DATA/Sim/Fibres.pts"
# cp "$DATA/Fibres.elem" "$DATA/Sim/Fibres.elem"
# cp "$DATA/Fibres.lon" "$DATA/Sim/Fibres.lon"
# cp "$DATA/LAT_Spiral4_B.dat" "$DATA/Sim/LAT_Spiral4_B.dat"

# cd $DATA/Sim/
# mpirun -np 10 carp.pt +F AF.par -simID Sim

done
