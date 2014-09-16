function [status]=write_trr(initstruct,trajstruct)
% [status]=write_trr(initstruct,trajstruct)
% Write a trr file and return status
% initstruct - filehandle from inittraj()
% trajstruct - trajectory structure from read_xtc or read_trr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright 2014 Jon Kapla
%%
%% This file is part of mxdrfile.
%%
%% mxdrfile is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% mxdrfile is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Lesser General Public License for more details.
%%
%% You should have received a copy of the GNU Lesser General Public License
%% along with Foobar. If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
