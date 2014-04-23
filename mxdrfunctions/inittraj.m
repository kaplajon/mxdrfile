function [status,trajinit]=inittraj(file,action)
% Open a trajectory file with either libxdrfile. Returns a libpointer
% filehandle and the number of atoms in the existing trajectory file as
% fields in a struct variable:
% init.handle
% init.natoms
%
% file (str) - filename of xtc or trr file to open
% action (str) - r or w for read or write access
%
% Jon Kapla, 2014-04-22
    natoms=0;
    status=0;
    [pathstr,name,ext] = fileparts(file);
    if(strcmp(action,'r'))
	if(strcmp(ext,'.xtc'))
	    [status,natoms]=read_xtc_natoms(file);
	elseif(strcmp(ext,'.trr'))
            [status,natoms]=read_trr_natoms(file);
	else
	    error('Only .trr and .xtc supported!')
	end
    elseif(strcmp(action,'w'))
	status=0
	natoms=0
    end
    catch_xdr_errors(status);
    trajinit.fhandle=calllib('libxdrfile','xdrfile_open',file,action);
    trajinit.fname=file;
    trajinit.natoms=natoms;
end % End function
