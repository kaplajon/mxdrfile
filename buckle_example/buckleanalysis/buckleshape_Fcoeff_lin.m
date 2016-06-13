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
% ML 2014-01-26

    function [X,Z,dXdg,dZdg,dXds,dZds,d2Xdg2,d2Zdg2,d2Xdgds,d2Zdgds,d2Xds2,d2Zds2]=...
    buckleshape_Fcoeff_lin(s,g,Lx)

persistent fx fdxds fd2xds2 fz fdzds fd2zds2 NC pp_x pp_dx pp_d2x pp_z pp_dz pp_d2z successfulTable
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

