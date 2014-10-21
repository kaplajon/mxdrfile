#  Using the Library with Matlab

## Installation

> cd my/path/to/mxdrfile
> make

Pay attention to any errors in the make procedure. If needed install required
libraries and/or consult the libxdrfile documentation.

> make test

If all went ok, the library can be loaded in Matlab with:

>loadmxdrfile

or

> addpath(genpath(fullpath('my','path','to','mxdrfile','mxdrfunctions')))
> loadlibrary('libxdrfile',@fileheaders)

##  Testing the Library

The library read and write functions can be tested by running the
included test scripts test_trr.m and test_xtc.m in Matlab after
completing the above install procedure.


# The mxdrfile Class

--> FILE: @mxdrfile/mxdrfile.m

USAGE: trj=mxdrfile(trajfile [,indexfile])

* trajfile - (str) Trajectory filename with .trr or .xtc extension
* indexfile - (str) OPTIONAL: Gromacs indexfile in .ndx format

## Class Properties:

* fname - (str) Trajectory filename
* ftype - (str) Trajectory filetype (by extension)
* fhandle - (1x1 lib.pointer) File handle for the open trajfile
* natoms - (int32) Number of atoms in trajectory
* status - (int32) Status of trajectory processing, 0=OK
* step - (int32) Trajectory step number
* time - (int32) Time in ps
* lam - (int32) Lambda
* box - (1x1 lib.pointer) box as a 3x3 matrix: value [3x3 single]
* x - (1x1 lib.pointer) Coordinates: value [3xnatoms single]
* v - (1x1 lib.pointer) Velocities (trr only): value [3xnatoms single]
* f - (1x1 lib.pointer) Forces (trr only):  value [3xnatoms single]
* prec - (int32) Precision of xtc files (default 1000)
* ndx - (1x1 struct) If indexfile is given field names are ndx groups: [nx1 int32]

## Class Methods

* read - read next frame in trajectory
* delete - Close trajectory file when the class object is destroyed

# The Wrapper Functions

## Open and Close

--> FILE: inittraj.m

USAGE: [status,initstruct]=inittraj(fname,action)

* fname - (str) Filename of .xtc or .trr file
* action - (str) 'r' or 'w' for read or write access. WARNING! 'w' will overwrite fname!!
* status - (int32)
* initstruct:
    * fhandle - (lib.pointer) XDR file handle
    * natoms - (int32) Number of atoms in trajectory

--> FILE: closetraj.m

USAGE: [status,initstruct]=closetraj(initstruct)
        Warning! Operating on a closed lib.pointer
        file handle may cause segmentation faults. Make sure
        to "pass by reference" using initstruct as both
        input and output when closing trajectories!

## Read

--> FILE: read_xtc.m

USAGE: [rstatus,trajstruct]=read_xtc(initstruct)

* status - int32
* trajstruct:
    * step - (int32) timestep
    * time - (single) time in ps
    * box - (singlePtr) Box as a 3x3 array
    * x - (singlePtr) Coordinates as an 3xnatoms array
    * natoms - (int32) Number of atoms in trajectory
    * prec - (single) Precision of XTC file

--> FILE: read_trr.m

USAGE: [rstatus,trajstruct]=read_xtc(initstruct)

* trajstruct:
    * step - (int32) timestep
    * time - (single) time in ps
    * lam - (single) lambda
    * box - (singlePtr) Box as a 3x3 array
    * x - (singlePtr) Coordinates as a 3xnatoms array
    * v - (singlePtr) Velocities as a 3xnatoms array
    * f - (singlePtr) Forces as a 3xnatoms array
    * natoms - (int32) Number of atoms in trajectory
    * prec - (single(1000.)) default precision for writing xtc

## Write

--> FILE: write_xtc.m

USAGE: wstatus=write_xtc(initstruct, trajstruct)

* wstatus - (int32)
* initstruct.fhandle - filehandle with writeaccess
* trajstruct:
    * step - (int32) timestep
    * time - (single) time in ps
    * box - (singlePtr) Box as a 3x3 array
    * x - (singlePtr) Coordinates as an 3xnatoms array
    * natoms - (int32) Number of atoms in trajectory
    * prec - (single) Precision of XTC file
	
--> FILE: write_trr.m

USAGE: wstatus=write_trr(initstruct, trajstruct)

* wstatus - (int32)
* initstruct.fhandle - filehandle with writeaccess
* trajstruct:
    * step - (int32) timestep
    * time - (single) time in ps
    * lam - (single) lambda
    * box - (singlePtr) Box as a 3x3 array
    * x - (singlePtr) Coordinates as a 3xnatoms array
    * v - (singlePtr) Velocities as a 3xnatoms array
    * f - (singlePtr) Forces as a 3xnatoms array
    * natoms - (int32) Number of atoms in trajectory

## Helpers

--> FILE: catch_xdr_errors.m

USAGE: catch_xdr_errors(status)
* status - int32

--> FILE: read_xtc_natoms.m

USAGE: [status,natoms]=read_xtc_natoms(fname)

* fname - (str) Filename with .xtc extension
* status - int32
* natoms - int32

--> FILE: read_trr_natoms.m

USAGE: [status,natoms]=read_trr_natoms(fname)

* fname - (str) Filename with .trr extension
* status - int32
* natoms - int32

--> FILE: read_ndx.m

USAGE: ndx=read_ndx(ndxfile)

* ndx - (1x1 struct) Field names are ndx-groups [nx1 int32]
* ndxfile - (str) Filename with .ndx extension
