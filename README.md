## Miriad 256

A copy of Miriad with support for 256 antennas (with modifications from M. Waterson/R. Wayth/R. Subrahmanyan). Larger numbers
may be possible and can be set in the `meson.build` file.

This version uses the [meson](https://mesonbuild.com/) build system, instead of the original `GNUMakefile` approach.

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

### Installation (ubuntu 22.04)

```
apt-get update 
apt-get install build-essential git libreadline-dev libreadline8 gfortran pgplot5 wcslib-dev libwcs7 libcfitsio9 libcfitsio-dev python3 python3-pip -y
pip install meson ninja
```

```
meson build --prefix=/usr/local/miriad
cd build; 
meson compile; 
meson install
```

### Installation (docker)

A (poorly tested) `Dockerfile` is included, however the PGPLOT outputs will not work without `x11docker` (which does not work on mac).

#### 256 antenna support

The maximum number of antennas supported is set in the `meson.build` file.

This is based on R. Wayth provided `sed` commands:

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
