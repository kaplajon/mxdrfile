function [status,traj]=read_trr(trajinit)
%function [status,tstep,ttime,tlam,tbox,tx,tv,tf]=read_trr(handle,natoms)
% Read a trr file and return step,time,box and coordinates (xyz)
% trajinit - filestructure from inittraj()
% traj.step (int32) - timestep
% traj.time (single) - time in ps
% traj.lam (single) - lambda
% traj.box (singlePtr) - box as a 3x3 array
% traj.(x, v, f) (singlePtr) - coords, velocities and force as 3*natoms array
%
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
