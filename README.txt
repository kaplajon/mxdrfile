Jon Kapla, 2014-04-17

-- The libxdrfile lib was compiled with the following:

> export MXWORKDIR=$PWD
> cd xdrfile-1.1.1
> ./configure --enable-shared --prefix=$MXWORKDIR
> make

-- The header files for libxdrfile had to be slightly altered to be loadable into
matlab. The altered files reside inside include/

-- The thunk library file and the fileheaders.m was created by running the
following command in matlab:

> loadlibrary('libxdrfile','xdrfile_xtc.h','addheader','xdrfile_trr','addheader','xdrfile','mfilename','fileheaders.m','thunkfile
 %name','libxdr_thunk')

 The library can then be loaded with: loadlibrary('libxdrfile',@fileheaders)
