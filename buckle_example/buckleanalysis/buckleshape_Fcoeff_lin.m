%[X,Z,dXdg,dZdg,dXds,dZds,d2Xdg2,d2Zdg2,d2Xdgds,d2Zdgds,d2Xds2,d2Zds2]=...
%    buckleshape_Fcoeff_lin(s,g,Lx)
%
% computes the parameterized shape X(s),Z(s) of a buckled periodic rod with
% projected x-length Lx, and compression factor g=Lx/L, where L is the
% total arclength. The parameter s has unit period, but all output are
% given in units of Lx, so that 0<x<Lx when 0<s<1. All partial derivatives
% are also returned.
%
% s can be a matrix, but g and Lx should be scalars. Output is the same
% shape as s (row or column vector).
%
% The curvature along s is given by
%
% C=-(dXds.*d2Zds2-dZds.*d2Xds2)./(dXds.^2+dZds.^2).^1.5;
%
% where the convention is that positive curvature curves away from the
% normal vector, which is in turn pointing upwards:
%
% nx = -dZds/sqrt(dXds.^2+dZds.^2),
% nz =  dXds/sqrt(dXds.^2+dZds.^2).
% 
% ML 2016-07-05

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

function [X,Z,dXdg,dZdg,dXds,dZds,d2Xdg2,d2Zdg2,d2Xdgds,d2Zdgds,d2Xds2,d2Zds2]=buckleshape_Fcoeff_lin(s,g,Lx)

persistent fx fdxds  fd2xds2 fz fdzds fd2zds2 NC pp_x pp_dx pp_d2x pp_z pp_dz pp_d2z successfulTable
if(isempty(successfulTable) || ~successfulTable) % then constuct persistent lookup tables
    successfulTable=false;
    R=load('XZfourier_tables');
    NC=size(R.ax,2); % number of Fourier coefficients

    % create Fourier functions for derivatives
    fz   =@(a,s)(  sum(diag(a)*(                               cos(2*pi*([1:2:(2*NC) 0]')*s)),1));
    fdzds=@(a,s)(  sum(diag(a(1:NC)'.*(2*pi*(1:2:(2*NC))))*(   -sin(2*pi*(1:2:(2*NC))'*s)),1));
    fd2zds2=@(a,s)(  sum(diag(a(1:NC)'.*(2*pi*(1:2:(2*NC))).^2)*(-cos(2*pi*(1:2:(2*NC))'*s)),1));

    fx     =@(a,s)(s+sum( diag(a)*(                   sin(4*pi*((1:NC)')*s)),1));
    fdxds  =@(a,s)(1+sum((diag(a'.*(4*pi*(1:NC))   )*( cos(4*pi*((1:NC)')*s))),1));
    fd2xds2=@(a,s)(  sum((diag(a'.*(4*pi*(1:NC)).^2)*(-sin(4*pi*((1:NC)')*s))),1));
        
    % create spline polynomials for gamma and derivatives wrt gamma
    pp_x=interp1(R.G,R.ax,'spline','pp');
    [pp_dx,pp_d2x]=splinediff(pp_x);
    pp_z=interp1(R.G,R.az,'spline','pp');
    [pp_dz,pp_d2z]=splinediff(pp_z);
    
    clear R
    successfulTable=true;
end
    % now evaluate functions and derivatives
    [sR,sC]=size(s);
    s=reshape(s,1,length(s));
    if(length(g)~=1 || length(Lx)~=1)
        error('One, and only one, value of g and Lx are needed in buckleshape_Fcoeff_lin')
    end

    X=reshape(Lx*fx(ppval(pp_x,g),s),sR,sC);
    Z=reshape(Lx*fz(ppval(pp_z,g),s),sR,sC);    
    dXdg=reshape(Lx*(fx(ppval(pp_dx,g),s)-s),sR,sC);
    dZdg=reshape(Lx*fz(ppval(pp_dz,g),s),sR,sC);
    dXds=reshape(Lx*fdxds(ppval(pp_x,g),s),sR,sC);
    dZds=reshape(Lx*fdzds(ppval(pp_z,g),s),sR,sC);
    d2Xdg2=reshape(Lx*(fx(ppval(pp_d2x,g),s)-s),sR,sC);
    d2Zdg2=reshape(Lx*fz(ppval(pp_d2z,g),s),sR,sC);
    d2Xdgds=reshape(Lx*(fdxds(ppval(pp_dx,g),s)-1),sR,sC);
    d2Zdgds=reshape(Lx*fdzds(ppval(pp_dz,g),s),sR,sC);
    d2Xds2=reshape(Lx*fd2xds2(ppval(pp_x,g),s),sR,sC);
    d2Zds2=reshape(Lx*fd2zds2(ppval(pp_z,g),s),sR,sC);
    

end
function [dpp,d2pp]=splinediff(pp)
    % compute spline polynomials for first and second derivatives of a
    % given spline polynomial pp. Taken from
    % http://www.mathworks.com/matlabcentral/answers/95194

    % extract details from piece-wise polynomial by breaking it apart
    [breaks,coefs,l,k,d] = unmkpp(pp);    
    % make the polynomial that describes the derivative
    dpp = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);

    % to calculate 2nd derivative differentiate the 1st derivative
    [breaks,coefs,l,k,d] = unmkpp(dpp);
    d2pp = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);
end

