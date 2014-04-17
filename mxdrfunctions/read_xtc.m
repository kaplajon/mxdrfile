function [status,tstep,ttime,tbox,tx]=read_xtc(handle,natoms)
% Read an xtc or trr file and return tstep,ttime,tbox and tx
% handle (libpointer) - filehandle from inittraj()
% natoms (int32) -  from traj_read_natoms
% tstep (int32Ptr) - step number
% ttime (singlePtr) - time in ps
% tbox (singlePtr) - Box as a 3x3 array
% tx (singlePtr) - Coordinates as a 3xnatoms array
% Jon Kapla, 2014-04-17

% Define pointers for frame extraction
    tstep=libpointer('int32Ptr',int32(0)); % Timestep
    ttime=libpointer('singlePtr',single(0)); % Time in ps
    tlam=libpointer('singlePtr',single(0)); % Lambda
    b(3,3)=single(0); 
    tbox=libpointer('singlePtr',b); % Box as a 3x3 matrix
    x(3,natoms)=single(0);
    tx=libpointer('singlePtr',x); % Coordinates as a 3xnatoms matrix
    prec=libpointer('singlePtr',single(1000)); % XTC file precision
% Library call
    func='read_xtc';
    args={'libxdrfile',func, handle, natoms, tstep, ttime, tbox, tx, prec};
    status=calllib(args{:});
end %End function
