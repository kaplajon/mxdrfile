% script to approximate X(s)/g, Z(s)/g by fourier series
% this needs to run only once, to produce a lookup table of Fourier
% coefficients that are then loaded and used by the fitting algorithms.
%
% ML 2014-03-25

if(1)
    clear
    G=linspace(0.15,1,30);
    az=[];
    ax=[];
    
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
            ax(k,:)=lsqcurvefit(fx,ones(1,3),ss,X);
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
            az(k,:)=lsqcurvefit(fz,[1 zeros(1,3)],ss,Z);
        else %manually set the coeficcients to zero for a straight line
            az(k,:)=0;
        end
        
        plot(ss,Z,'b','linew',2)
        %plot(ss,fz(az(k,:),ss)-Z,'g--')
        plot(ss,fz(az(k,:),ss),'r-.','linew',2)
        ylabel('Z(s) / L_x')
        box on
        xlabel('s')
        legend('numerical bvp','Fourier approx.',3)
        
        figure(1)
        subplot(2,1,1)
        hold on
        plot(G(k)*fx(ax(k,:),ss),G(k)*fz(az(k,:),ss),'g-.','linew',2)
        legend('initial guess','numerical bvp','Fourier approx')
        
        pause(0.5)
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
