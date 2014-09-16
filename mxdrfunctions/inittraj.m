function [status,trajinit]=inittraj(file,action)
% [status,trajinit]=inittraj(file,action)
% Open a trajectory file with either libxdrfile. Returns a libpointer
% filehandle and the number of atoms in the existing trajectory file as
% fields in a struct variable:
% trajinit.handle
% trajinit.natoms
%
% file (str) - filename of xtc or trr file to open
% action (str) - r or w for read or write access
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright 2014 Jon Kapla
%%
%% This file is part of xdrfile-matlab.
%%
%% xdrfile-matlab is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% xdrfile-matlab is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Lesser General Public License for more details.
%%
%% You should have received a copy of the GNU Lesser General Public License
%% along with Foobar. If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
	status=0;
	natoms=0;
    end
    catch_xdr_errors(status);
    trajinit.fhandle=calllib('libxdrfile','xdrfile_open',file,action);
    trajinit.fname=file;
    trajinit.natoms=natoms;
end % End function
