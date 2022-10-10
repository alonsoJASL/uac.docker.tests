# QUICK GUIDE 
Docker containers have to be **pulled** -like git repos. 
Make sure you get the right version, as the container described here is new, 
you will need to call it with its full name `docker pull cemrg/uac:3.0-alpha`. 

+ `cermg` : Corresponds to the organisation the container is from 
+ `uac`   : is the name of the container
+ `3.0-alpha` : is the **tag**, which denotes the version. 

If you forget typing the `3.0-alpha`, docker will serve you the `latest` tag, 
which is at the moment pointing to version `v2.0`.

To call our container you must indicate the main path to your data. 

``` shell
docker run --rm --volume=/path/to/your/DATA:/data cemrg/uac:3.0-alpha COMMAND PARAMETERS 
```

> NOTE: if in `PARAMETERS` you need to add filenames or paths, you will need to 
> specify **relative paths** to `/path/to/your/DATA`


## UAC + Fibre Mapping (4 chamber hearts) 

**Inputs in example folder:** 
+ Mesh Folders: `LA_endo, LA_epi`, `RA_endo , RA_epi` 
+ Landmarks Folders: `Landmarks/XX/ prodXxLandmarks.txt, prodXxRegion.txt` with  `XX={LA,RA}`

You will work in the `LA_endo, _epi ` and `RA_endo,_epi` folders, 
where the outputs will be saved. 


### 1. Copy the example folder

For simplicity, we assume your data folder is in variable `$DATA`

> We will walk you through the processing of LA endo, you can change names and 
> parameters accordingly to do LA epi, RA endo and RA epi 

Copy the base parameter files from the corresponding directories. 
In our case, working in `LA_endo` this would look like 

```
cp /path/to/example/Landmarks/LA/prodLaLandmarks.txt $DATA/Landmarks.txt
cp /path/to/example/Regions/LA/prodLaRegions.txt $DATA/Regions.txt
```
NOTE: you do not need to change the names of the files when copying as the filename is sent as parameter.


-------------------------------------------------------------------------------

### 2. UAC
There are 2 stages to calculating UAC: 1, 2a, and 2b, 
in between the stages there are calls to openCARP for the Laplace solves. 
Parameters and options of the `uac` mode of operation: 

+ `--uac-stage`: Which stage of the processing: `{1, 2a, 2b}`
+ `--atrium`: Choose between `la` or `ra`
+ `--layer` : Choose between `endo`, `epi` or `bilayer` (this is necessary to specify but it does not have impact on the UAC)
+ `--fourch`: indicates the container to use the 4 Chamber variant of the code.
+ `--msh`   : indicate the mesh name in carp format (no extension)
+ `--landmarks` : indicate name with extension of Landmarks file 
+ `--regions` : indicate name with extension of Regions file 




#### 2.1 UAC. Stage 1
``` shell
docker run --rm --volume=$DATA:/data cemrg/uac:3.0-alpha uac --uac-stage 1 --atrium la --layer endo --fourch --msh MeshName --landmarks Landmarks.txt --regions Regions.txt --scale 1000 
```

-------------------------------------------------------------------------------

**Laplace Solves (1).**
You need to get the parameter files for the posterior-anterior (`PA`) and 
the `LS` coordinates. These are copied from the container with command `getparfile`

``` shell
docker run --rm --volume=$DATA:/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_LS --lapsolve-msh LA_only 
docker run --rm --volume=$DATA:/data cemrg/uac:3.0-alpha getparfile --lapsolve-par carpf_laplace_PA --lapsolve-msh LA_only 
```
> Using the `--lapsolve-msh` option allows to change the name of the mesh on the 
> first line of the parameter file 

The openCARP can also be called from docker (or locally)

``` shell
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_PA.par -simID PA_UAC_N2
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_LS.par -simID LR_UAC_N2

```
-------------------------------------------------------------------------------

#### 2.2a UAC. Stage 2a
Notice the only change is in the `--uac-stage` parameter from `1` to `2a`
``` shell
docker run --rm --volume=$DATA:/data cemrg/uac:3.0-alpha uac --uac-stage 2a --atrium la --layer endo --fourch --msh MeshName --landmarks Landmarks.txt --regions Regions.txt --scale 1000 
```

**Laplace solves (2a)**
Four Laplace solves are needed here, so we need to call `getparfile` 4 times: 
Two anterior (`LR_A, UD_A`) and two posterior (`LR_P, UD_P`)
```shell
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_P"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_P"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_LR_A"
docker run --rm --volume="$DATA":/data cemrg/uac:3.0-alpha getparfile --lapsolve-par "carpf_laplace_single_UD_A"

```

Followed by openCARP

``` shell
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_A.par -simID LR_Ant_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_LR_P.par -simID LR_Post_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_A.par -simID UD_Ant_UAC
docker run --rm --volume="$DATA":/shared:z --workdir=/shared docker.opencarp.org/opencarp/opencarp:latest openCARP +F carpf_laplace_single_UD_P.par -simID UD_Post_UAC

```

#### 2.2b UAC. Stage 2b
Again, the only change is in the `--uac-stage` parameter from `2a` to `2b`
``` shell
docker run --rm --volume=$DATA:/data cemrg/uac:3.0-alpha uac --uac-stage 2b --atrium la --layer endo --fourch --msh MeshName --landmarks Landmarks.txt --regions Regions.txt --scale 1000 
```
