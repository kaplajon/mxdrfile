% [xzg,s,x,z]=fit_min2D_buckle(xzgInit,sInit,xx,zz,Lx)
% fit (X,Z) to an Esuler buckling shape, minimizing the sum of squares i
% both x and z-directions.
%
% fit function: x(i) = x0 + Lx*X(s(i),g);
%               z(i) = z0 + Lx*Z(s(i),g)
%
% objective fun: sum_i (X(i)-x(i))^2+(Z(i)-z(i))^2
%
% free fit parameters: x0, z0, g, s(1:end)
%
% input:
% xzgInit=[x;z;g]: initial guess for curve parameters
% sInit          : initial guess for arclength parameters (period = 1).
% xx,zz          : fit points, in the same units as Lx.
% Lx : box-length in x direction, sets length scale of the problem
% output: 
%   xzg=[x0 z0 g] : curve fit parameters
%   s,x,z :         points (x,z) on the curve, and corresponding phase parameters s.
%
% g=Lx/L=1-gamma is a compression factor
% ML 2014-01-27

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
function [xzg,s,x,z]=fit_min2D_buckle(xzgInit,sInit,xx,zz,Lx)

q0=[xzgInit; sInit]; % initial guess

fObj=@(q)(chi2_grad_buckle(q(1),q(2),q(3),q(4:end),xx,zz,Lx));

opt=optimset('Gradobj','on','Hessian','on',...
    'tolfun',1e-9,'tolx',1e-12,'maxiter',1e4,'display','notify-detailed');

qq=fminunc(fObj,q0,opt);
xzg=qq(1:3);
s=qq(4:end);
[~,~,~,x,z]=fObj(qq);
    
end

function [chi2,grad,hess,X,Z]=chi2_grad_buckle(x0,z0,g,s,xx,zz,Lx)
% objective functions (gradient and hessian) for 2D-fitting a general shape
% function: x = x0 + Lx*X(s,g);
%           z = z0 + Lx*Z(s,g);

[X,Z,dXdg,dZdg,dXds,dZds,d2Xdg2,d2Zdg2,d2Xdgds,d2Zdgds,d2Xds2,d2Zds2]=...
    buckleshape_Fcoeff_lin(s,g,Lx);

dx=x0+X-xx;
dz=z0+Z-zz;
N=length(s);

chi2=sum(dx.^2+dz.^2);

%disp(num2str([chi2 x0 z0 g max(abs(dz)) max(abs(dx))]))
    
% grad = [dx0; dz0 ; dg ; ds1 ; ds2 ; ... ; dsN]
    
grad=[2*sum(dx);
    2*sum(dz);
    2*sum(dx.*dXdg+dz.*dZdg);
    2*dx.*dXds+2*dz.*dZds];
        
% hessian
    
d2XIdxdg=2*sum(dXdg);
d2XIdzdg=2*sum(dZdg);
d2XIdg2 =2*sum(dXdg.^2+dx.*d2Xdg2+dZdg.^2+dz.*d2Zdg2);
    
%%% try sparse matrices, or preallocate them?
hess_x0z0g=2*[N             0     d2XIdxdg;
              0             N     d2XIdzdg;
              d2XIdxdg   d2XIdzdg d2XIdg2];
    hess_sij=2*diag(dXds.^2+dx.*d2Xds2+dZds.^2+dz.*d2Zds2);
    hess_xzg_s = 2*[dXds dZds ...
        (dXdg.*dXds+dx.*d2Xdgds+dZdg.*dZds+dz.*d2Zdgds)];
    
    hess=[hess_x0z0g hess_xzg_s';
          hess_xzg_s hess_sij];
      
    X=X+x0;
    Z=Z+z0;
end
