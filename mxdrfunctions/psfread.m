function [B,title]=psfread(psffilename)
% [B,title]=psfread(psffilename)
%
% read bond matrix from psf file
%
% M.L. 2013-01-03

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This function reads a psf file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This file is part of mxdrfile.
%%
%% Copyright © 2016 Martin Lindén. All Rights Reserved.
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


fid=fopen(psffilename,'r'); % open for reading
tline = fgetl(fid);
isbondblock=false;
B=[];
while ischar(tline)
    % look for end of bond block
    if(~isempty(strfind(tline,'!N')) && isempty(strfind(tline,'!NBOND')))
        isbondblock=false;
    end
     if(isbondblock)
         % read bond information
         % disp(['bond block: ' tline])
         Bfoo=str2num(tline);
         B=[B;Bfoo(1:2:end)' Bfoo(2:2:end)'];
     else
         %disp(tline)
     end
     % look for beginning of bond block
    if(~isempty(strfind(tline,'!NBOND')))
         isbondblock=true;
    end    
    
    % look for title block and read title
    if(~isempty(strfind(tline,'REMARKS system name :')))
        nc=strfind(tline,':');
        ns=strfind(tline,' '); 
        nt=1+ns(find(ns>nc,1)); % title starts at first non-space char after first :
        title=tline(nt:end);
        while(strcmp(title(end),' ')) % shave off trailing spaces
            title=title(1:end-1);
        end
        clear nt nc ns
    end
    
    tline = fgetl(fid);
end


