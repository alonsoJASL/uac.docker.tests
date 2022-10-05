#!/bin/bash


PROJECT="$HOME/uac-refact"
DATA="$HOME/tests-refact/4ch"

me=$(basename "$0" | awk -F. '{print $1}')
logfile=$DATA/$me"_"$(date +'%m%d%Y').log


docker run --rm --volume="$DATA/LA_vol":/data getparfile --lapsolve-par "carpf_laplace_alpha.par"
docker run --rm --volume="$DATA/LA_vol":/data getparfile --lapsolve-par "carpf_laplace_beta.par"
docker run --rm --volume="$DATA/LA_vol":/data getparfile --lapsolve-par "carpf_laplace_EE.par"

###meshalyzer "/home/caroline/Documents/Atrial_fibre/0$i/0$i/LA_vol/LA_vol." --compSurf
meshtool convert -imsh=$DATA/LA_vol/LA_vol.vtk -omsh=$DATA/LA_vol/LA_only -ofmt=carp_txt -scale=1000

meshtool extract surface -msh=$DATA/LA_vol/LA_only -surf=$DATA/LA_vol/LA_only

# python $PROJECT/uac/volumetric_vtx.py "$DATA/LA_vol/" "$DATA/LA_endo/" "$DATA/LA_epi/" LA_only LA_only LA_only
docker run --rm --volume="$DATA/LA_vol/":/data cemrg/uac:3.0-alpha 


docker run --rm --volume="$DATA/LA_vol":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_alpha.par -simID Alpha
docker run --rm --volume="$DATA/LA_vol":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_beta.par -simID Beta
docker run --rm --volume="$DATA/LA_vol":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_EE.par -simID EndoEpi


# python $PROJECT/uac/volumetric_write_mesh.py "$DATA/LA_vol/" "$DATA/LA_endo/" "$DATA/LA_epi/" LA_only LA_only LA_only
docker run --rm --volume="$DATA/LA_vol/":/data cemrg/uac:3.0-alpha 

cp "$DATA/LA_vol/LA_only.elem" "$DATA/LA_vol/Mesh_UAC_3D.elem"
cp "$DATA/LA_vol/LA_only.surf" "$DATA/LA_vol/Mesh_UAC_3D.surf"




docker run --rm --volume="$DATA/RA_vol":/data getparfile --lapsolve-par "carpf_laplace_alpha.par"
docker run --rm --volume="$DATA/RA_vol":/data getparfile --lapsolve-par "carpf_laplace_beta.par"
docker run --rm --volume="$DATA/RA_vol":/data getparfile --lapsolve-par "carpf_laplace_EE.par"

meshtool convert -imsh=$DATA/RA_vol/RA_vol.vtk -omsh=$DATA/RA_vol/RA_only -ofmt=carp_txt -scale=1000

meshtool extract surface -msh=$DATA/RA_vol/RA_only -surf=$DATA/RA_vol/RA_only

# python $PROJECT/uac/volumetric_vtx.py "$DATA/RA_vol/" "$DATA/RA_endo/" "$DATA/RA_epi/" RA_only RA_only RA_only
docker run --rm --volume="$DATA/RA_vol/":/data cemrg/uac:3.0-alpha 


docker run --rm --volume="$DATA/RA_vol":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_alpha.par -simID Alpha
docker run --rm --volume="$DATA/RA_vol":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_beta.par -simID Beta
docker run --rm --volume="$DATA/RA_vol":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_EE.par -simID EndoEpi

# python $PROJECT/uac/volumetric_write_mesh.py "$DATA/RA_vol/" "$DATA/RA_endo/" "$DATA/RA_epi/" RA_only RA_only RA_only
docker run --rm --volume="$DATA/RA_vol/":/data cemrg/uac:3.0-alpha 


cp "$DATA/RA_vol/RA_only.elem" "$DATA/RA_vol/Mesh_UAC_3D.elem"
cp "$DATA/RA_vol/RA_only.surf" "$DATA/RA_vol/Mesh_UAC_3D.surf"


# python $PROJECT/uac/fibre_mapping.py "$DATA/LA_endo/" "$PROJECT/fibre_files/la/endo/l/" "$PROJECT/laplace_files/" LA_only Labelled.lon Fibre_Labarthe
docker run --rm --volume="$DATA/LA_endo/":/data cemrg/uac:3.0-alpha 

# python $PROJECT/uac/fibre_mapping.py "$DATA/LA_epi/" "$PROJECT/fibre_files/la/epi/l/" "$PROJECT/laplace_files/" Labelled Labelled.lon Fibre_Labarthe
docker run --rm --volume="$DATA/LA_epi/":/data cemrg/uac:3.0-alpha 

#now threshold fibres LA
# python $PROJECT/uac/fibre_mapping_volumetric_threshold.py "$DATA/LA_vol/" LA_only Mesh_UAC_3D "$DATA/LA_endo/" LA_only Fibre_Labarthe.vec "$DATA/LA_epi/" LA_only Fibre_Labarthe.vec Fibre_T.vec
docker run --rm --volume="$DATA/LA_vol/":/data cemrg/uac:3.0-alpha 


##Fibre mapping bilayer for RA
# python $PROJECT/uac/fibre_mapping.py "$DATA/RA_epi/" "$PROJECT/fibre_files/ra/epi/l/" "$PROJECT/laplace_files/" Labelled Labelled.lon Fibre_Labarthe
docker run --rm --volume="$DATA/RA_epi/":/data cemrg/uac:3.0-alpha 



# python $PROJECT/uac/fibre_mapping_volumetric_threshold_ra.py "$DATA/RA_vol/" RA_only Mesh_UAC_3D "$DATA/RA_epi/" RA_only Labelled_Epi "$DATA/RA_epi/" RA_only Fibre_Labarthe "$DATA/RA_epi/" Fibre_T.vec
docker run --rm --volume="$DATA/RA_vol/":/data cemrg/uac:3.0-alpha 



#now merge them
meshtool merge meshes -msh1="$DATA/LA_vol/Fibres_Threshold" -msh2="$DATA/RA_vol/Fibres_Threshold" -ofmt=carp_txt -outmsh="$DATA/RA_vol/MergeVol_Threshold"

#meshtool extract surface -msh=$DATA/RA_vol/MergeVol_Threshold -surf=$DATA/RA_vol/MergeVol_Threshold

meshtool extract mesh -msh=$DATA/RA_vol/MergeVol_Threshold -tags=3 -submsh=$DATA/RA_vol/LA_mesh -ofmt=vtk

meshtool convert -imsh=$DATA/RA_vol/LA_mesh.vtk -omsh=$DATA/RA_vol/LA_mesh -ofmt=carp_txt

meshtool extract surface -msh=$DATA/RA_vol/LA_mesh -surf=$DATA/RA_vol/LA_mesh

meshtool extract mesh -msh=$DATA/RA_vol/MergeVol_Threshold -tags=4 -submsh=$DATA/RA_vol/RA_mesh -ofmt=vtk
meshtool convert -imsh=$DATA/RA_vol/RA_mesh.vtk -omsh=$DATA/RA_vol/RA_mesh -ofmt=carp_txt

meshtool extract surface -msh=$DATA/RA_vol/RA_mesh -surf=$DATA/RA_vol/RA_mesh

meshtool extract mesh -msh=$DATA/RA_vol/MergeVol_Threshold -tags=5,8,9 -submsh=$DATA/RA_vol/RA_structures -ofmt=vtk
meshtool convert -imsh=$DATA/RA_vol/RA_structures.vtk -omsh=$DATA/RA_vol/RA_structures -ofmt=carp_txt

meshtool extract surface -msh=$DATA/RA_vol/RA_structures -surf=$DATA/RA_vol/RA_structures



#code to visualise fibres
# python $PROJECT/uac/biatrial_volumetric_visualisation.py "$DATA/RA_vol/" MergeVol_Threshold
docker run --rm --volume="$DATA/RA_vol/":/data cemrg/uac:3.0-alpha 

#now add in LAT field - write this code
# python $PROJECT/uac/lat_field_volumetric_biatrial.py "$DATA/LA_vol/" "$DATA/RA_vol/" LAT_Spiral4_B.dat Fibres_Threshold Fibres_Threshold MergeVol_Threshold
docker run --rm --volume="$DATA/LA_vol/":/data cemrg/uac:3.0-alpha 
