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
function [status,natoms]=read_xtc_natoms(file)
% Reads an xtc or trr file and returns natoms
% 
% Jon Kapla, 2014-04-17
        na=libpointer('int32Ptr',int32(0));
        status=calllib('libxdrfile','read_xtc_natoms',file,na);
        natoms=na.value
end % End function
