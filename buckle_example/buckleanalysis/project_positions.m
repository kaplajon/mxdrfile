% [xp zp sp] =  project_positions(xxl,zzl,ssl,xr,zr,Lx)
%
% function to get projected x positions from a given set of points to a
% numerical curve. The curve is given by xxl,zzl, which are presumed to
% have beend parameterized by an arclength-like parameter ssl, i.e., 
%
% xxl(i) = Fx(ssl(i)), zzl(i) = Fz(ssl(i)), for some functions Fx, Fz
% 
% The projected positions are xp,zp are choosen from the set (xxl,zzl) to
% minimize the total square distance min_i (xp-xxl(i))^2+(zp-zzl(i))^2,
% together with the corresponding arc-lengths ssl(i). 
%
% Everything is supposed to periodic in x with period Lx, and with period
% Ls in s, so 0 =< xr < Lx is enforced before the projection takes place.
% (ML: this seems incomplete, should not xxl and ssl be forced into the
% corresponding constraints as well? I just added warning though.)
%
% input:     xxl,zzl: the curve into which points project
%            ssl    : arcl lengths of (xx,zz)
%            xr, zr : points to project
%            Lx     : periodicity in x,  
% output:    xp: projected x positions
%            zp: projected z positions
%            sp: projected arclengths
% INPUTS should be aligned xx and zz

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


function [xp,zp,sp] =  project_positions(xxl,zzl,ssl,xr,zr,Lx)
%prealocations
xp=zeros(size(xr));
zp=xp; sp=xp;


xr=mod(xr,Lx); %must avoid nans (out of range)

%warning(['ML suspects that xxl and ssl should also be projected to the ' ...
%         'interval  [0, Lx] and [0,1] respectively, before projecting.'])

%CHECK: OK! 
% ssc=cumtrapz(xxl(2:end), sqrt( 1+ (diff(zzl)./diff(xxl)).^2 ));

for ii=1:length(xr)
    dist2 = (xxl-xr(ii)).^2 + (zzl-zr(ii)).^2 ;
    [~,ix] = min(dist2);
    xp(ii) = xxl(ix);
    zp(ii) = zzl(ix);
    sp(ii) = ssl(ix);
end

end

