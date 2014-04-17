function [status]=write_xtc(handle,natoms,step,time,tbox,tx,prec)
% Write an xtc or trr file and return tstep,ttime,tbox and tx
% handle (libpointer) - filehandle from inittraj()
% natoms (int32) -  from traj_read_natoms
% step (int32) - timestep
% time (single) - time in ps
% tbox (singlePtr) - box as a 3x3 array
% tx (singlePtr) - Coordinates as a 3*natoms array
% prec (single) - Precision of xtc file (default 1000)
% Jon Kapla, 2014-04-17
% Library call
    func='write_xtc';
    args={'libxdrfile',func, handle, natoms, step, time, tbox, tx, prec};
    status=calllib(args{:});
end %End function
