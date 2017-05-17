% script to approximate X(s)/g, Z(s)/g by fourier series
% this needs to run only once, to produce a lookup table of Fourier
% coefficients that are then loaded and used by the fitting algorithms.
%
% ML 2014-03-25

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

if(1)
    clear
    G=linspace(0.15,1,30);
    az=[];
    ax=[];
    Ncoeff=3;
    for k=1:length(G)
        B=buckleshape_half_bvp(G(k),true);
        ss=linspace(-0.5,0.5,1e5);
        X=deval(B,ss,3)/G(k);
        Z=deval(B,ss,4)/G(k);
        title([' Lx/L = ' num2str(G(k)) ])
        
        %% fit and plot
        fz=@(a,s)(  sum(diag(a)*(cos(2*pi*([(1:2:(2*(length(a)-1))) 0]')*s)),1));
        fx=@(a,s)(s+sum(diag(a)*(sin(4*pi*([  1:(length(a)  )]')*s)),1));
        
        figure(5)
        clf
        subplot(2,1,1)
        hold on
        if(abs(G(k)-1)>1e-15) 
            ax(k,:)=lsqcurvefit(fx,ones(1,Ncoeff),ss,X);
        else %manually set the coeficcients to zero for a straight line
            ax(k,:)=0;
        end
        
        plot(ss,X-ss,'b','linew',2)
        %plot(ss,fx(ax(k,:),ss)-X,'g--')
        plot(ss,fx(ax(k,:),ss)-ss,'r-.','linew',2)
        ylabel('X(s) / L_x - s ')
        box on
        xlabel('s')
        
        subplot(2,1,2)
        hold on
        if(abs(G(k)-1)>1e-15) 
            az(k,:)=lsqcurvefit(fz,[1 zeros(1,Ncoeff)],ss,Z);
        else %manually set the coeficcients to zero for a straight line
            az(k,:)=0;
        end
        
        plot(ss,Z,'b','linew',2)
        %plot(ss,fz(az(k,:),ss)-Z,'g--')
        plot(ss,fz(az(k,:),ss),'r-.','linew',2)
        ylabel('Z(s) / L_x')
        box on
        xlabel('s')
        legend('numerical bvp','Fourier approx.')
        
        figure(1)
        subplot(2,1,1)
        hold on
        plot(G(k)*fx(ax(k,:),ss),G(k)*fz(az(k,:),ss),'g-.','linew',2)
        legend('initial guess','numerical bvp','Fourier approx')
        
        pause(0.1)
    end
    
    save XZfourier_tables.mat G ax az fx fz
else
    clear
    load XZfourier_tables.mat
end
%% plot coefficients
figure(7)
clf
subplot(2,1,1)
hold on
plot(G,log(ax),'-k.')
ylabel('log(a_n^{(x)})')
box on
axis([0.14 1 -20 1])

subplot(2,1,2)
plot(G,log(-az),'-r.')
xlabel('L_x / L')
ylabel('log( -a_n^{(z)})')
box on
axis([0.14 1 -20 1])

figure(2)
clf
subplot(2,1,1)
hold on
plot(G,ax,'-k.')
ylabel('a_n^{(x)}')
box on
axis([0.14 1 -0.01 0.4])

subplot(2,1,2)
plot(G,az,'-r.')
xlabel('L_x / L')
ylabel('a_n^{(z)}')
box on
axis([0.14 1 -1.8 0.02])
%% plot arclength check
ss=linspace(0,1,1e4);
dsDiff=0*G;
dsIntDiff=0*G;
for n=1:numel(G)
    [X,Z,dXdg,dZdg,dXds,dZds,d2Xdg2,d2Zdg2,d2Xdgds,d2Zdgds,d2Xds2,d2Zds2]=buckleshape_Fcoeff_lin(ss,G(n),1);
    dsDiff(n)=max(abs(sqrt(dXds.^2+dZds.^2)-1/G(n)));
    dsIntDiff(n)=trapz(sqrt(dXds.^2+dZds.^2))*mean(diff(ss))-1/G(n);
end

figure(3)
clf
hold on
plot(G,dsDiff,'k')
plot(G,abs(dsIntDiff),'b')
set(gca,'yscale','log')
xlabel('L_x / L')
ylabel('\nabla_s(x,z) -1/g')
legend('max(|...|)','|\Deltaarclength|')
title('normalization anomaly of tangent vector')


