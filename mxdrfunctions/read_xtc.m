function [status,traj]=read_xtc(trajinit)
% [status,traj]=read_xtc(initstruct)
% Read an xtc or trr file and return tstep,ttime,tbox and tx
% initstruct - from inittraj()
% traj.step (int32) - step number
% traj.time (single) - time in ps
% traj.box (singlePtr) - Box as a 3x3 array, use traj.box.value to get the actual numbers
% traj.x (singlePtr) - Coordinates as a 3xnatoms array, use traj.x.value to access the coordinates
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of mxdrfile.
%%
%% Copyright © 2014 Jon Kapla. All Rights Reserved.
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are
%% met:
%%
%% 1. Redistributions of source code must retain the above copyright
%%    notice,this list of conditions and the following disclaimer.
%%
%% 2. Redistributions in binary form must reproduce the above copyright
%%    notice, this list of conditions and the following disclaimer in the
%%    documentation and/or other materials provided with the distribution.
%%
%% 3. The name of the author may not be used to endorse or promote products
%%    derived from this software without specific prior written permission.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS"
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
%% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
%% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
%% DIRECT,INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
%% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
%% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
%% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%% POSSIBILITY OF SUCH DAMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check for open file handle
if(~strcmp(class(trajinit.fhandle),'lib.pointer'))
    catch_xdr_errors(12)
end
traj=struct;
% Define pointers for frame extraction
    tstep=libpointer('int32Ptr',int32(0)); % Timestep
    ttime=libpointer('singlePtr',single(0)); % Time in ps
    tlam=libpointer('singlePtr',single(0)); % Lambda
    b(3,3)=single(0); 
    tbox=libpointer('singlePtr',b); % Box as a 3x3 matrix
    x(3,trajinit.natoms)=single(0);
    tx=libpointer('singlePtr',x); % Coordinates as a 3xnatoms matrix
    prec=libpointer('singlePtr',single(0)); % XTC file precision
% Library call
    func='read_xtc';
    args={'libxdrfile',func, trajinit.fhandle,trajinit.natoms, tstep, ttime, tbox, tx, prec};
    status=calllib(args{:});
    catch_xdr_errors(status);
% Assign output
    traj.step=tstep.value;
    traj.time=ttime.value;
    traj.box=tbox;
    traj.x=tx;
    traj.natoms=trajinit.natoms;
    traj.prec=prec.value;
end %End function
