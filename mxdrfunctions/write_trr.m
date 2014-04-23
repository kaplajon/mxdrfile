function [status]=write_trr(initstruct,trajstruct)
% Write a trr file and return status
% initstruct - filehandle from inittraj()
% trajstruct - trajectory structure from read_xtc or read_trr
%
% Jon Kapla, 2014-04-22

% Add fields if trajstruct comes from read_xtc()
if(isfield(trajstruct,'v')) 
    trajstruct.v=trajstruct.x;
    trajstruct.v.value=0;
end
if(isfield(trajstruct,'f')) 
    trajstruct.f=trajstruct.x;
    trajstruct.f.value=0;
end
if(isfield(trajstruct,'lam')) 
    trajstruct.lam=0;
end

% Library call
    func='write_trr';
    args={'libxdrfile',func, initstruct.fhandle, trajstruct.natoms, trajstruct.step, trajstruct.time,...
    trajstruct.lam, trajstruct.box, trajstruct.x, trajstruct.v, trajstruct.f};
    status=calllib(args{:});
    catch_xdr_errors(status);
end %End function
