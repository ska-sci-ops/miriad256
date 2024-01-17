## Miriad 256

A copy of Miriad with support for 256 antennas (with modifications from M. Waterson/R. Wayth/R. Subrahmanyan).

#### Installation notes for Ubuntu 22.04

We copied this source code to `/usr/local/miriad`, then ran

```
./configure --with-wcslib=/usr/lib/x86_64-linux-gnu --prefix=/usr/local/miriad
make
```

The install needs `gfortran` and `readline`, but when running miriad it demands
older versions of `libgfortran` and `libreadline`, which we copied over from 
micromamba:

```bash
micromamba create -n aavs
micromamba install libgfortran4
cp ~/micromamba/envs/aavs/lib/libgfortran.so* /usr/local/miriad/linux64/lib/

micromamba install readline=7.0
cp ~/micromamba/envs/aavs/lib/libreadline* /usr/local/miriad/linux64/lib/
```

To make sure these are found, we then added two lines to the end of `MIRRC.sh`:

```
 export LD_LIBRARY_PATH=$MIRLIB:$LD_LIBRARY_PATH
 export PATH=$MIRBIN:$PATH
```

(Note: these lines may disappear after running `make`, as it updates `MIRRC.sh`, so may need to be re-added). 

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
