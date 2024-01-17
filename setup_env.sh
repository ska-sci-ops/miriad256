
# Installation script for Ubuntu 22.04 PC in "Science Dungeon:
MIR=/usr/local/miriad  
export MIR

#DCP: libgfortran4 shared library has been copied over from a micromamba install 
# and is now housed in ./lib. We add this to LD_LIBRARY_PATH for dynamic linking
export LD_LIBRARY_PATH=$MIR/lib:$LD_LIBRARY_PATH

# DCP: Now add rpfits and pgplot shared library locations to LD_LIBRARY_PATH
# These are probably found automatically, but adding just in case
export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib

# DCP: Run installation configure script, passing wcslib installation location
./configure --with-wcslib=/usr/lib/x86_64-linux-gnu --prefix=/usr/local/miriad

# DCP: Now run make
make
