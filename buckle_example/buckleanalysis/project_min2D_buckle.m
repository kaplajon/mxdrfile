% [s,x,z]=project_min2D_buckle(xzg,sInit,xx,zz,Lx)
%
% fit s(i) to a fixed Euler buckling shape, minimizing the sum of squares i
% both x and z-directions.
%
% fit function: x(i) = x0 + Lx*X(s(i),g);
%               z(i) = z0 + Lx*Z(s(i),g)
%
% objective fun: sum_i (X(i)-x(i))^2+(Z(i)-z(i))^2
%
% free fit parameters : s(1:end)
% fixed parameters    : x0,z0,g,Lx 
%
% input:
% xzgInit=[x;z;g] : initial guess for curve parameters
% sInit           : initial guess for arclength parameters (period = 1).
% xx,zz           : fit points, in the same units as Lx.
% Lx : box-length in x direction, sets length scale of the problem
% output: 
%   s,x,z         : points (x,z) on the curve, and corresponding phase
%                   parameters s.
%
% ML 2014-03-31

function [s,x,z]=project_min2D_buckle(xzg,sInit,xx,zz,Lx)

% fit function
fObj=@(q)(chi2_grad_buckle(xzg(1),xzg(2),xzg(3),q,xx,zz,Lx));

opt=optimset('Gradobj','on','Hessian','on',...
    'tolfun',1e-9,'tolx',1e-12,'maxiter',1e4,'display','notify-detailed');

s=fminunc(fObj,sInit,opt);
[~,~,~,x,z]=fObj(s);
    
end

function [chi2,grad,hess,X,Z]=chi2_grad_buckle(x0,z0,g,s,xx,zz,Lx)
% objective functions (gradient and hessian) for 2D-fitting a general shape
% function: x = x0 + Lx*X(s,g);
%           z = z0 + Lx*Z(s,g);

[X,Z,~,~,dXds,dZds,~,~,~,~,d2Xds2,d2Zds2]=...
    buckleshape_Fcoeff_lin(s,g,Lx);

dx=x0+X-xx;
dz=z0+Z-zz;
N=length(s);

chi2=sum(dx.^2+dz.^2);

%disp(num2str([chi2 x0 z0 g max(abs(dz)) max(abs(dx))]))
    
% grad = [ds1 ; ds2 ; ... ; dsN]
    
grad=[2*dx.*dXds+2*dz.*dZds];
        
% hessian
%%% try sparse matrices, or preallocate them?
hess=2*diag(dXds.^2+dx.*d2Xds2+dZds.^2+dz.*d2Zds2);
X=X+x0;
Z=Z+z0;
end
