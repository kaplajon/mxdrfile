function [status,natoms]=read_trr_natoms(file)
% Reads an xtc or trr file and returns natoms
% 
% Jon Kapla, 2014-04-17
        na=libpointer('int32Ptr',int32(0));
        status=calllib('libxdrfile','read_trr_natoms',file,na);
        natoms=na.value
end % End function
