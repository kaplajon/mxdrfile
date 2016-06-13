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

