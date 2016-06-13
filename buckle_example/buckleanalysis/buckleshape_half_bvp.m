function [sol,guess]=buckleshape_half_bvp(Lx,doplot)
% [sol,guess]=buckleshape_bvp(Lx,doplot);
% compute the shape of a buckled elastica (arclength 1) numerically, using
% bvp4c, on the interval -1/2 < s <1/2. A (surprisingly good) initial guess
% on the form theta(s) = a*sin(2*pi*s) is also provided. Symmetries around
% s=0 are constructed numerically (by solving on half the interval and then
% symmetrizing).  
%
% The parameter p is the buckling tension, in units of the bending
% stiffness.
%
% if doplot=true, the solution and initial guess are also plotted.
%
% sol.y=[theta; theta' ; x ; y];
% sol.x=s, arclength
%
% input parameter: projected length Lx in buckling direction, in units of
% total arclength, -1<Lx<1 (the initial guess is decent for about
% 0.25<Lx<1). 

% ML 2014-01-22

%% compute a (surprisingly) good initial guess
%v=@(s)((1-cos(4*pi*s)).*(1-2*(s>=0.5)));
%dvds=@(s)(4*pi*sin(4*pi*s).*(1-2*(s>=0.5)));

v=@(s)(sin(2*pi*s));
dvds=@(s)(2*pi*cos(2*pi*s));

opt=optimset(@fsolve);opt=optimset(opt,'Display','off');
Lxf=@(a)(quadl(@(s)(cos(a*v(s))),-0.5,0.5));
a=fsolve(@(a)(Lxf(a)-Lx),0.1,opt);
dLxda=quadl(@(s)(-sin(a*v(s)).*v(s)),-0.5,0.5);
p0=-2*pi^2*a/dLxda;

% initial guess on -1/2<s<1/2
s=linspace(-0.5,0.5,101);ds=s(2)-s(1);
theta0=a*v(s);
x=-Lx/2+cumtrapz(cos(theta0))*ds;
z=cumtrapz(sin(theta0))*ds;

guess.a=a;
guess.p=p0;
guess.x=s;
guess.y=[a*v(s);a*dvds(s);x;z];

% initial guess on -1/2<s<0
s=linspace(-0.5,0,101);ds=s(2)-s(1);
theta0=a*v(s);
x=cumtrapz(cos(theta0))*ds;
z=cumtrapz(sin(theta0))*ds;


%% setup and solve bvp with lagrange multiplier, on 0<s<0.5
% (0<s<0.5 follows by symmetry)

% y=[theta; theta' ; x ; y];
odefun=@(t,y,p)([y(2);-p*sin(y(1));cos(y(1));sin(y(1))]);
bcfun=@(ya,yb,p)([ya(1);yb(1);ya(3)+Lx/2;ya(4);yb(3)]);

initfun=@(ss,p)([a*v(ss);
    a*dvds(ss);
    interp1(s,x,ss,'pchip');
    interp1(s,z,ss,'pchip')]);
solinit=bvpinit(s,initfun,0.5);
opt=bvpset('reltol',1e-9,'abstol',1e-12);

sol4=bvp4c(odefun,bcfun,solinit,opt);
% symmetrize
sol.x=[sol4.x -sol4.x(end-1:-1:1)];
sol.y=[sol4.y(1,:) -sol4.y(1,end-1:-1:1);
       sol4.y(2,:)  sol4.y(2,end-1:-1:1);
       sol4.y(3,:) -sol4.y(3,end-1:-1:1);
       sol4.y(4,:)  sol4.y(4,end-1:-1:1)];
   
sol.yp=[sol4.yp(1,:)  sol4.yp(1,end-1:-1:1);
        sol4.yp(2,:) -sol4.yp(2,end-1:-1:1);
        sol4.yp(3,:)  sol4.yp(3,end-1:-1:1);
        sol4.yp(4,:) -sol4.yp(4,end-1:-1:1)];
    
if(exist('doplot','var') && doplot==true) % make a plot
    figure(1)
    clf
    subplot(2,1,1)
    hold on
    %plot(x,z,'--r','linewidth',2)
    plot(guess.y(3,:),guess.y(4,:),'--r','linewidth',2)
    plot(sol.y(3,:),sol.y(4,:),'-k','linewidth',2)
    %plot(Lx-x,z,'--r','linewidth',2)
    %plot(Lx-sol.y(3,:),sol.y(4,:),'-k','linewidth',2)
    
    axis equal
    xlabel('x/L')
    ylabel('z/L')
    g=gca;
    box on
    
    subplot(2,1,2)
    hold on
    %plot(s,180/pi*theta0,'--r','linewidth',2)
    plot(guess.x,180/pi*guess.y(1,:),'--r','linewidth',2)
    plot(sol.x,180/pi*sol.y(1,:),'-k','linewidth',2)
    %plot(-s,-180/pi*theta0,'--r','linewidth',2)
    %plot(-sol.x,-180/pi*sol.y(1,:),'-k','linewidth',2)

    xlabel('s/L')
    ylabel('\theta [^o]')
    box on
    legend('solution','initial guess')
end
