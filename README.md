### Miriad 256

A copy of Miriad with support for 256 antennas (with modifications from M. Waterson/R. Wayth/R. Subrahmanyan).

##### Installation notes for Ubuntu 22.04

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

