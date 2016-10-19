function pdb2gro(grofile,a,sysname,t0,aw)
% pdb2gro(grofile,a,sysname,t0,aw)
%
% convert a pdb structure to gromacs gro-format, with zero velocities
% 
% grofile   filename of grofile to create. If existing, the file is
%           overwritten.
% a         Matlab pdb structure
% sysname   string with name of system, to match the corresponding 
%           [ system ] entry in the .top file
% t0        (optional) time in ps (default 0)
% aw        argument to fopen (default 'w')
%
% ML 2013-01-xx
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This function writes a .gro file starting from a pdg struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  
if(~exist('t0','var')|| isempty(t0))
    t0=0;
end
if(~exist('aw','var'))
    aw='w';
end

fid=fopen(grofile,aw); % open and overwrite

% title string (free format string, optional time in ps after 't=')
fprintf(fid,'%s t= %f\n',sysname,t0);
%fprintf('%s t= %f\n',sysname,t0);

% number of atoms (free format integer)
N=length(a.Model.Atom);
fprintf(fid,'%5d\n',N);
%fprintf('%5d\n',N);

% one line for each atom (fixed format, see below)
% Note: pdb uses Å, while .gro uses nm
for k=1:N
    resNum=a.Model.Atom(k).resSeq;
    res=a.Model.Atom(k).resName;
    aName=a.Model.Atom(k).AtomName;
    aNum=a.Model.Atom(k).AtomSerNo;
    x=a.Model.Atom(k).X/10;
    y=a.Model.Atom(k).Y/10;
    z=a.Model.Atom(k).Z/10;
    vx=0;vy=0;vz=0;
    
    fprintf(fid,'%5d%-5s%5s%5d%8.3f%8.3f%8.3f%8.4f%8.4f%8.4f\n',...
        resNum,res,aName,aNum,x,y,z,vx,vy,vz);
    
    % new, from gromacs manual, with spaces in strings
    %fprintf(fid,'%5d%-5s%5s%5d%8.3f%8.3f%8.3f%8.4f%8.4f%8.4f\n',...
    %    resNum,res,aName,aNum,x,y,z,vx,vy,vz);

end

% box vectors (free format, space separated reals), values: v1(x) v2(y) v3(z) v1(y) v1(z) v2(x) v2(z) v3(x) v3(y), the last 6 values may be omitted (they will be set to zero). Gromacs only supports boxes with v1(y)=v1(z)=v2(z)=0. 
% Here, a rectangular box with 
fprintf(fid,'%f %f %f\n',a.Cryst1.a/10,a.Cryst1.b/10,a.Cryst1.c/10);
%fprintf('%f %f %f\n',    a.Cryst1.a/10,a.Cryst1.b/10,a.Cryst1.c/10);

fclose(fid);
