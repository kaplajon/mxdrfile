function [status]=write_xtc(initstruct,trajstruct)
% [status]=write_xtc(initstruct,trajstruct)
% Write an xtc or trr file and return tstep,ttime,tbox and tx
% initstruct - filehandle from inittraj()
% trajstruct - trajectory structure from read_xtc() or read_trr()
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

% Library call
    func='write_xtc';
    args={'libxdrfile',func, initstruct.fhandle, trajstruct.natoms, trajstruct.step, trajstruct.time, trajstruct.box, trajstruct.x, trajstruct.prec};
    status=calllib(args{:});
    catch_xdr_errors(status);
end %End function
