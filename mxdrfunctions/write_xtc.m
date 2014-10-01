function [status]=write_xtc(initstruct,trajstruct)
% [status]=write_xtc(initstruct,trajstruct)
% Write an xtc or trr file and return tstep,ttime,tbox and tx
% initstruct - filehandle from inittraj()
% trajstruct - trajectory structure from read_xtc() or read_trr()
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
if(~strcmp(class(initstruct.fhandle),'lib.pointer'))
    catch_xdr_errors(12)
end

% Library call
    func='write_xtc';
    args={'libxdrfile',func, initstruct.fhandle, trajstruct.natoms, trajstruct.step, trajstruct.time, trajstruct.box, trajstruct.x, trajstruct.prec};
    %status=calllib('libxdrfile',func, initstruct.fhandle,...
    %    trajstruct.natoms, trajstruct.step, trajstruct.time,...
    %    trajstruct.box, trajstruct.x,single(1000))% trajstruct.prec);
    status=calllib(args{:});
    catch_xdr_errors(status);
end %End function
