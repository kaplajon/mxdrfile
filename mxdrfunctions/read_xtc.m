function [status,traj]=read_xtc(trajinit)
% Read an xtc or trr file and return tstep,ttime,tbox and tx
% initstruct - from inittraj()
% traj.step (int32) - step number
% traj.time (single) - time in ps
% traj.box (singlePtr) - Box as a 3x3 array, use traj.box.value to get the actual numbers
% traj.x (singlePtr) - Coordinates as a 3xnatoms array, use traj.x.value to access the coordinates

% Jon Kapla, 2014-04-22
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
