%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright 2014 Jon Kapla
%%
%% This file is part of xdrfile-matlab.
%%
%% xdrfile-matlab is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% xdrfile-matlab is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Lesser General Public License for more details.
%%
%% You should have received a copy of the GNU Lesser General Public License
%% along with Foobar. If not, see <http://www.gnu.org/licenses/>.
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
infile='test.trr';
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
