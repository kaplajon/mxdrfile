function [status,tstep,ttime,tlam,tbox,tx,tv,tf]=read_trr(handle,natoms)
% Read an xtc or trr file and return tstep,ttime,tbox and tx
% handle (libpointer) - filehandle from inittraj()
% natoms (int32) -  from traj_read_natoms
% tstep (int32Ptr) - timestep
% ttime (singlePtr) - time in ps
% tlam (singlePtr) - lambda
% tbox (singlePtr) - box as a 3x3 array
% tx, tv, tf - coords, velocities and force as 3*natoms array
% Jon Kapla, 2014-04-17

% Define pointers for frame extraction
    tstep=libpointer('int32Ptr',int32(0)); % Timestep
    ttime=libpointer('singlePtr',single(0)); % Time in ps
    tlam=libpointer('singlePtr',single(0)); % Lambda
    b(3,3)=single(0); 
    tbox=libpointer('singlePtr',b); % Box as a 3x3 matrix
    x(3,natoms)=single(0);
    tx=libpointer('singlePtr',x); % Coordinates as a 3xnatoms matrix
    tv=libpointer('singlePtr',x); % Coordinates as a 3xnatoms matrix
    tf=libpointer('singlePtr',x); % Coordinates as a 3xnatoms matrix
    % Library call
    func='read_trr';
    args={'libxdrfile',func, handle, natoms, tstep, ttime,tlam, tbox, tx, tv, tf};
    status=calllib(args{:});
end %End function
