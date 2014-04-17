function [status]=write_trr(handle,natoms,step,time,lam,tbox,tx,tv,tf)
% Write a trr file and return status
% handle (libpointer) - filehandle from inittraj()
% natoms (int32) -  from read_trr_natoms
% step (int32) - step number
% time (single) - time in ps
% lam (single) - lambda
% tbox (singlePtr) - Box as a 3x3 array
% tx, tv, tf (singlePtr) - coordinates, velocities and forces as 3xnatoms arrays
% Jon Kapla, 2014-04-17

% Library call
    func='write_trr';
    args={'libxdrfile',func, handle, natoms, step, time,lam, tbox, tx, tv, tf};
    status=calllib(args{:});

end %End function
