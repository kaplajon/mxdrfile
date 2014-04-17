%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Jon Kapla, 2014-04-17, jon.kapla@mmk.su.se
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This script tests the read and write of
%% trr files with libxdrfile from gmx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir0=pwd;
addpath(genpath([dir0 filesep 'mxdrfunctions']))
addpath(genpath([dir0 filesep 'lib']))
addpath(genpath([dir0 filesep 'include']))
if(not(libisloaded('libxdrfile'))) % Load XDR functions
    [notfound,warnings]=loadlibrary('libxdrfile',@fileheaders);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
infile='eq.trr';
[pathstr,name,ext] = fileparts(infile);
intype=ext;
outfile='testwrite.trr';
[pathstr,name,ext] = fileparts(outfile);
outtype=ext;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inhandle=libpointer;
inhandle=inittraj(infile,'r');
outhandle=libpointer;
outhandle=inittraj(outfile,'w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[status,natoms]=read_trr_natoms(infile);
frame=0;
while true % Frameloop
    [rstatus,tstep,ttime,tlam,tbox,tx,tv,tf]=read_trr(inhandle,natoms);
    % Do something with the coordinates
    newcoords=tx;
    newcoords.val=newcoords.val*0.8;
    % Write newcoords to a new xtc file
    wstatus=write_trr(outhandle, natoms, tstep.value, ttime.value, tlam.value, tbox, newcoords, tv, tf);
    if(not(rstatus))
        frame=frame+1;
	disp('Frame'),disp(frame)
    else
        break
    end
end
status=closetraj(inhandle)
status=closetraj(outhandle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
