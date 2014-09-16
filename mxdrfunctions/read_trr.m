function [status,traj]=read_trr(trajinit)
%function [status,traj]=read_trr(trajinit)
% Read a trr file and return step,time,box and coordinates (xyz)
% trajinit - filestructure from inittraj()
% traj.step (int32) - timestep
% traj.time (single) - time in ps
% traj.lam (single) - lambda
% traj.box (singlePtr) - box as a 3x3 array
% traj.(x, v, f) (singlePtr) - coords, velocities and force as 3*natoms array
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
%% along with Foobar. If not, see <http://www.gnu.org/licenses/>.
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
    tv=libpointer('singlePtr',x); % Velocities as a 3xnatoms matrix
    tf=libpointer('singlePtr',x); % Forces as a 3xnatoms matrix
    % Library call
    func='read_trr';
    args={'libxdrfile',func, trajinit.fhandle, trajinit.natoms, tstep, ttime, tlam, tbox, tx, tv, tf};
    status=calllib(args{:});
    % libxdrfile: read_trr() never returns exdrENDOFFILE but exdrINT instead
    if(status==4 && trajinit.natoms~=0)
	status=11;
    end
    catch_xdr_errors(status);
% Assign output
    traj.step=tstep.value;
    traj.time=ttime.value;
    traj.lam=tlam.value;
    traj.box=tbox;
    traj.x=tx;
    traj.v=tv;
    traj.f=tf;
    traj.natoms=trajinit.natoms;
    traj.prec=single(1000); %default precision for writing xtc
end %End function
