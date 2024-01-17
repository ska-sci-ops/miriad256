## Miriad 256

A copy of Miriad with support for 256 antennas (with modifications from M. Waterson/R. Wayth/R. Subrahmanyan).


### Installation (Mac)

Use homebrew to install fortran, compile tools, and the PGPLOT replacement `giza`:

```
brew install pkgconfig cmake gfortran gcc-13 giza
```

Note the homebrew version of `wcslib` does not have fortran support.
But we can get this from python/conda:

```
conda install cfitsio readline wcslib meson
```

You'll then need to set some environment variables:

```
export CC=gcc-13
export CONDA_ENV_PATH=/Users/daniel.price/local/mamba/envs/aa3
export LIBRARY_PATH=$MAMBA_ENV_PATH/lib 
```


#### 256 antenna support

The maximum number of antennas supported is set in a file called `maxdim.h`. We ran the following `sed` commands
to enable support:

```bash
export F77=gfortran
sudo chmod u+w inc/linux64/*.h
sudo chmod u+w prog/*
sudo chmod u+w subs/*
sudo sed -i~ 's/MAXANT = 64/MAXANT = 256/' inc/linux64/maxdim.h
sudo sed -i~ 's/MAXANT 64/MAXANT 256/' inc/linux64/maxdimc.h
sudo sed -i~ 's/MAXCHAN = 70000/MAXCHAN = 4096/' inc/linux64/maxdim.h
sudo sed -i~ 's/MAXCHAN 70000/MAXCHAN 4096/' inc/linux64/maxdimc.h
sudo sed -i~ 's/MAXAVER=2000000/MAXAVER=80000000/' prog/uvspec.h
sudo sed -i~ 's/MAXAVER=2000000/MAXAVER=100000000/' prog/uvaver.h
sudo sed -i~ 's/maxbase2 = 91/maxbase2 = 512/' prog/uvplt.for
```
