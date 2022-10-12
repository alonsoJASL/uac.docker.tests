# README

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

## Useful parameters 
+ Each `COMMAND` has a `help` option with usage information. 
+ Use option `--debug` to see a the command that would be run inside the container.

## Tutorials
+ [Example 1. LA,RA extracted from a 4ch mesh](https://github.com/alonsoJASL/uac.docker.tests/blob/master/base_fourch/quick_guide.md) 
