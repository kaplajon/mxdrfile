function [status]=write_trr(initstruct,trajstruct)
% Write a trr file and return status
% initstruct - filehandle from inittraj()
% trajstruct - trajectory structure from read_xtc or read_trr
%
% Jon Kapla, 2014-04-22

% Add fields if trajstruct comes from read_xtc()
if(~isfield(trajstruct,'v')) 
    v(3,trajinit.natoms)=single(0);
    trajstruct.v=libpointer('singlePtr',v);
    disp('write_trr: Adding field v');
end
if(~isfield(trajstruct,'f')) 
    f(3,trajinit.natoms)=single(0);
    trajstruct.v=libpointer('singlePtr',f);
    disp('write_trr: Adding field f');
end
if(~isfield(trajstruct,'lam')) 
    trajstruct.lam=single(0);
    disp('write_trr: Adding field lam');
end

% Library call
    func='write_trr';
    args={'libxdrfile',func, initstruct.fhandle, trajstruct.natoms, trajstruct.step, trajstruct.time,...
    trajstruct.lam, trajstruct.box, trajstruct.x, trajstruct.v, trajstruct.f};
    status=calllib(args{:});
    catch_xdr_errors(status);
end %End function
