function [status,traj]=read_xtc(trajinit)
% [status,traj]=read_xtc(initstruct)
% Read an xtc or trr file and return tstep,ttime,tbox and tx
% initstruct - from inittraj()
% traj.step (int32) - step number
% traj.time (single) - time in ps
% traj.box (singlePtr) - Box as a 3x3 array, use traj.box.value to get the actual numbers
% traj.x (singlePtr) - Coordinates as a 3xnatoms array, use traj.x.value to access the coordinates
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright 2014 Jon Kapla
%%
%% This file is part of mxdrfile.
%%
%% mxdrfile is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% mxdrfile is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Lesser General Public License for more details.
%%
%% You should have received a copy of the GNU Lesser General Public License
%% along with mxdrfile. If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
traj=struct;
% Define pointers for frame extraction
    tstep=libpointer('int32Ptr',int32(0)); % Timestep
    ttime=libpointer('singlePtr',single(0)); % Time in ps
    tlam=libpointer('singlePtr',single(0)); % Lambda
    b(3,3)=single(0); 
    tbox=libpointer('singlePtr',b); % Box as a 3x3 matrix
    x(3,trajinit.natoms)=single(0);
    tx=libpointer('singlePtr',x); % Coordinates as a 3xnatoms matrix
    prec=libpointer('singlePtr',single(0)); % XTC file precision
% Library call
    func='read_xtc';
    args={'libxdrfile',func, trajinit.fhandle,trajinit.natoms, tstep, ttime, tbox, tx, prec};
    status=calllib(args{:});
    catch_xdr_errors(status);
% Assign output
    traj.step=tstep.value;
    traj.time=ttime.value;
    traj.box=tbox;
    traj.x=tx;
    traj.natoms=trajinit.natoms;
    traj.prec=prec.value;
end %End function
