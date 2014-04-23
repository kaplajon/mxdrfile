function [status]=write_xtc(initstruct,trajstruct)
% Write an xtc or trr file and return tstep,ttime,tbox and tx
% initstruct - filehandle from inittraj()
% trajstruct - trajectory structure from read_xtc() or read_trr()
% Jon Kapla, 2014-04-22
% Library call
    func='write_xtc';
    args={'libxdrfile',func, initstruct.fhandle, trajstruct.natoms, trajstruct.step, trajstruct.time, trajstruct.box, trajstruct.x, trajstruct.prec};
    status=calllib(args{:});
    catch_xdr_errors(status);
end %End function
