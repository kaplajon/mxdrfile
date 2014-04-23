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
outfile='testwrite.trr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,rTraj]=inittraj(infile,'r');
[~,wTraj]=inittraj(outfile,'w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frame=0;
while true % Frameloop
    [rstatus,traj]=read_trr(rTraj);
    if(not(rstatus))
        frame=frame+1;
	disp('Frame'),disp(frame)
    else
        break
    end
    % Do something with the coordinates
    % Write newcoords to a new xtc file
    traj.x.value=traj.x.value*0.8;
    wstatus=write_trr(wTraj,traj);
end
status=closetraj(rTraj);
status=closetraj(wTraj);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
