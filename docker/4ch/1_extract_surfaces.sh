#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ] ; then
    >&2 echo 'No arguments supplied'
    >&2 echo '  PROJECT - UAC project folder'
    >&2 echo '  inputPath - keeps the Landmarks/ folder and the 01-350um.vtk test case'
    exit 1
fi

SCRIPT_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]}  ) &> /dev/null && pwd )

PROJECT=$1
inputPath=$2

me=$(basename "$0" | awk -F. '{print $1}')
logfile=$inputPath/$me"_"$(date +'%m%d%Y').log

outputPath1=$inputPath/LA_1
outputPath2=$inputPath/LA_2
outputPath3=$inputPath/RA_1
outputPath4=$inputPath/RA_2
outputPath5=$inputPath/LA_vol
outputPath6=$inputPath/RA_vol

echo "$inputPath" >> $logfile
echo "$outputPath1" >> $logfile

echo "Creating output folders" >> $logfile
mkdir ${outputPath1}
mkdir ${outputPath2}
mkdir ${outputPath3}
mkdir ${outputPath4}
mkdir ${outputPath5}
mkdir ${outputPath6}

echo "Extracting LA" >> $logfile
meshtool extract  surface -msh=${inputPath}/01-350um.vtk -surf=${inputPath}/LA -ofmt=vtk -op=3-14,7,8,9,10,11,18,19,20,21,22

meshtool extract unreachable -msh=${inputPath}/LA.surfmesh.vtk -submsh=${inputPath}/LA_cc -ofmt=vtk

meshtool convert -imsh=${inputPath}/LA_cc.part1.vtk -omsh=${outputPath1}/LA_1 -ofmt=carp_txt
meshtool convert -imsh=${inputPath}/LA_cc.part0.vtk -omsh=${outputPath2}/LA_2 -ofmt=carp_txt
cp ${inputPath}/LA_cc.part1.vtk ${outputPath1}/LA_1.vtk
cp ${inputPath}/LA_cc.part0.vtk ${outputPath2}/LA_2.vtk

echo "Extracting RA" >> $logfile
meshtool extract surface -msh=${inputPath}/01-350um.vtk -surf=${inputPath}/RA -ofmt=vtk -op=4-12,13,15,23,24

meshtool extract unreachable -msh=${inputPath}/RA.surfmesh.vtk -submsh=${inputPath}/RA_cc -ofmt=vtk

meshtool convert -imsh=${inputPath}/RA_cc.part1.vtk -omsh=${outputPath3}/RA_1 -ofmt=carp_txt
meshtool convert -imsh=${inputPath}/RA_cc.part0.vtk -omsh=${outputPath4}/RA_2 -ofmt=carp_txt
cp ${inputPath}/RA_cc.part1.vtk ${outputPath3}/RA_1.vtk
cp ${inputPath}/RA_cc.part0.vtk ${outputPath4}/RA_2.vtk

rm ${inputPath}/01-350um.fcon

echo "Extracting Volumetric" >> $logfile
meshtool extract mesh -msh=${inputPath}/01-350um.vtk -tags=3 -submsh=${outputPath5}/LA_vol -ofmt=vtk
meshtool convert -imsh=${outputPath5}/LA_vol.vtk -omsh=${outputPath5}/LA_vol -ofmt=carp_txt

meshtool extract mesh -msh=${inputPath}/01-350um.vtk -tags=4 -submsh=${outputPath6}/RA_vol -ofmt=vtk
meshtool convert -imsh=${outputPath6}/RA_vol.vtk -omsh=${outputPath6}/RA_vol -ofmt=carp_txt

python $PROJECT/uac/label_endo_epi_surfaces.py ${inputPath}/ LA_1 LA_2 RA_1 RA_2
