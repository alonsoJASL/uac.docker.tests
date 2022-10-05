#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  EXAMPLES_DIR'
    >&2 echo '  atrium {la, ra}'
    exit 1
fi

EXAMPLES_DIR="$1"
l="$2"

me=$(basename "$0" | awk -F. '{print $1}')
logfile=$EXAMPLES_DIR/$me"_"$(date +'%m%d%Y').log

for i in {1..7}
do

DATA="$EXAMPLES_DIR/$l/epi/$i"

echo "$DATA" >> $logfile
echo "=====Add fibres 2=====" >> $logfile
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha fibremap --atrium $l --layer endo --fibre $i --msh Labelled --output "Fibres_$i"

echo "=====Add fibres 2 Bilayer=====" >> $logfile
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha fibremap --atrium $l --layer bilayer --fibre $i --msh Labelled --output "FFB$i"

echo "=====Add LAT field ($i)=====" >> $logfile
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha latfield --lat-type normal --lat-file LAT_Spiral4_B.dat --msh "Fibres_$i"

echo "=====Make PV stimulus files .vtx ($i)=====" >> $logfile
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha stim --msh Labelled --tags 11 13 21 23 25 27

# mkdir $DATA/Sim
# cp "$PROJECT/SimulationFiles/AF_100.par" "$DATA/Sim/AF.par"
# cp "$DATA/Fibres.pts" "$DATA/Sim/Fibres.pts"
# cp "$DATA/Fibres.elem" "$DATA/Sim/Fibres.elem"
# cp "$DATA/Fibres.lon" "$DATA/Sim/Fibres.lon"
# cp "$DATA/LAT_Spiral4_B.dat" "$DATA/Sim/LAT_Spiral4_B.dat"

# cd $DATA/Sim/
# mpirun -np 10 carp.pt +F AF.par -simID Sim

done
