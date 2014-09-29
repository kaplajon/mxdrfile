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
