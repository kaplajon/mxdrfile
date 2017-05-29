% script to evaluate trucation errors for various number of terms in the
% Fourier approximation of X(s)/g, Z(s)/g. 
%
% ML 2014-03-25
%
% Modified to 


if(1) % set 0 to use precomputed values and just plot 
    clear
    Nrange=2:9;    
    Nplot=[3 7];
    G=linspace(0.15,0.95,17);
    ax=cell(0);
    az=cell(0);
    for N=Nrange
       ax{N}=[];
       az{N}=[];
    end
    
    for k=1:length(G)
        B=buckleshape_half_bvp(G(k),true);
        ss=linspace(-0.5,0.5,1e5);
        X=deval(B,ss,3)/G(k);
        Z=deval(B,ss,4)/G(k);
        Cn{k}=-deval(B,ss,2)*G(k); % curvature        
        title([' Lx/L = ' num2str(G(k)) ])
        
        %% fit and plot
        fz=@(a,s)(  sum(diag(a)*(cos(2*pi*([(1:2:(2*(length(a)-1))) 0]')*s)),1)); %a0 is last in a
        fx=@(a,s)(s+sum(diag(a)*(sin(4*pi*([  1:(length(a)  )]')*s)),1));
        
        for N=Nrange
            if(N==Nrange(1))
                a0=ones(1,N);
            end
            if(abs(G(k)-1)>1e-15)
                ax{N}(k,:)=lsqcurvefit(fx,a0,ss,X);
                a0=[ax{N}(k,:) 0];
            else %manually set the coeficcients to zero for a straight line
                ax(k,:)=0;
            end
        end
        for N=Nrange
            if(N==Nrange(1))
                a0=ones(1,N+1);
            end
            if(abs(G(k)-1)>1e-15)
                az{N}(k,:)=lsqcurvefit(fz,a0,ss,Z);
                a0=[az{N}(k,:) 0];
            else %manually set the coeficcients to zero for a straight line
                az(k,:)=0;
            end
        end
        
        %% X,Z solutions
        figure(5)
        clf
        subplot(2,1,1)
        hold on
        plot(ss,X-ss,'b','linew',2)
        for N=Nplot
            plot(ss,fx(ax{N}(k,:),ss)-ss,'r-','linew',1)
        end
        ylabel('X(s) / L_x - s ')
        box on
        xlabel('s')
                
        subplot(2,1,2)
        hold on
        plot(ss,Z,'b','linew',2)
        for N=Nplot
            plot(ss,fz(az{N}(k,:),ss),'r-','linew',1)
        end
        ylabel('Z(s) / L_x')
        box on
        xlabel('s')
        legend('numerical bvp','Fourier approx.')
        %% plot residuals
        figure(6) % residuals
        clf
        subplot(2,1,1)
        hold on
        for N=Nplot
            plot(ss,fx(ax{N}(k,:),ss)-X,'r-','linew',1)
        end
        ylabel('\DeltaX(s) / L_x ')
        box on
        xlabel('s')
                
        subplot(2,1,2)
        hold on
        for N=Nplot
            plot(ss,fz(az{N}(k,:),ss)-Z,'r-','linew',1)
        end
        ylabel('\DeltaZ(s) / L_x')
        box on
        xlabel('s')        
        %% 2D shape
        figure(1)
        subplot(2,1,1)
        hold on
        for N=Nplot
            plot(G(k)*fx(ax{N}(k,:),ss),G(k)*fz(az{N}(k,:),ss),'g-','linew',1)
        end
        legend('initial guess','numerical bvp','Fourier approx')
        %% evaluate various deviation norms
        for N=Nrange
            L2x(k,N) =sqrt(mean((fx(ax{N}(k,:),ss)-X).^2));
            L2z(k,N) =sqrt(mean((fz(az{N}(k,:),ss)-Z).^2));
            L2xz(k,N)=sqrt(mean((fx(ax{N}(k,:),ss)-X).^2 + (fz(az{N}(k,:),ss)-Z).^2));
            
            L1x(k,N) =mean(abs(fx(ax{N}(k,:),ss)-X));
            L1z(k,N) =mean(abs(fz(az{N}(k,:),ss)-Z));
            L1xz(k,N)=mean(sqrt((fx(ax{N}(k,:),ss)-X).^2 + (fz(az{N}(k,:),ss)-Z).^2));
            
            LIx(k,N) =max(abs(fx(ax{N}(k,:),ss)-X));
            LIz(k,N) =max(abs(fz(az{N}(k,:),ss)-Z));
            LIxz(k,N)=max(sqrt((fx(ax{N}(k,:),ss)-X).^2 + (fz(az{N}(k,:),ss)-Z).^2));
        end
        pause(0.1)
    end
    
    for k=1:numel(G)
        for N=Nrange
            % note: G is rally too sparse for good interpolations in
            % buckleshape_Fcoeff_eval, but we are evaluating at interpolation
            % points only, and not differentiating wrt g, soi othis should be
            % fine
            [~,~,~,~,dXds,dZds,~,~,~,~,d2Xds2,d2Zds2]=buckleshape_Fcoeff_eval(ss,G(k),1,G,ax{N},az{N});
            Cf=-(dXds.*d2Zds2-dZds.*d2Xds2)./(dXds.^2+dZds.^2).^1.5;
            LIc(k,N)=max(abs((Cf-Cn{k})));
        end
    end

    
    save XZfourier_coeff.mat 
else
    clear
    load XZfourier_coeff.mat
end
%% maximum 2D deviation 
figure(22)
clf
hold on
Nplot=[2 3 5 7];
col='kmbr';
leg={};
for n=1:numel(Nplot)
    plot(1-G,LIxz(:,Nplot(n)),'k-','color',col(n))
    leg{end+1}=['N=' int2str(Nplot(n))];
end
xlabel('\gamma')
ylabel('L_\infty(\Deltax,\Deltaz) / L_x')
ylabel('max_s ||(X-X_N, Z-Z_N)|| / L_x')
ylabel('max_s ||X-X_N, Z-Z_N|| / L_x')
set(gca,'yscale','log')
axis([0 0.9 1e-12 1])
box on
legend(leg,'location','northwest')
grid off
exportfig(22,'XZdeviation.eps','width',7.35,'height',7)
%% curvature deviations
figure(31)
clf
hold on
Nplot=[2 3 5 7];
col='kmbr';
leg={};
for n=1:numel(Nplot)
    plot(1-G,LIc(:,Nplot(n)),'k-','color',col(n))
    leg{end+1}=['N=' int2str(Nplot(n))];
end
xlabel('\gamma')
ylabel('max_s |K(s)-K_N(s)|\timesL_x')
set(gca,'yscale','log')
axis([0 0.9 1e-12 1])
box on
legend(leg,'location','southeast')
grid off

exportfig(31,'curvatureDeviation.eps','width',7.35,'height',7)
%% stop here
error('stop here!')
%% plot coefficients
N=max(Nrange);

figure(7)
clf
subplot(2,1,1)
hold on
plot(G,abs(ax{N}),'-k.')
ylabel('|a_n^{(x)}|')
box on
set(gca,'yscale','log')
axis([0.14 1 1e-12 1])

subplot(2,1,2)
plot(G,abs(az{N}(:,1:end-1)),'-r.')
xlabel('L_x / L')
ylabel('|a_n^{(z)}|')
set(gca,'yscale','log')
box on
axis([0.14 1 1e-12 2])


figure(8)
clf
subplot(2,1,1)
hold on
plot(G,ax{N},'-k.')
ylabel('a_n^{(x)}')
box on
axis([0.14 1 -0.01 0.4])

subplot(2,1,2)
plot(G,az{N},'-r.')
xlabel('L_x / L')
ylabel('a_n^{(z)}')
box on
axis([0.14 1 -1.8 0.02])
%% plot all residual norms
figure(21)
clf
Yvar={'L2x','L2z','L2xz',...
      'L1x','L1z','L1xz',...
      'LIx','LIz','LIxz'};
col='rbm';
Lnorm={'L_2','L_1','L_\infty'}
for v=1:9
    cc=1+mod(v-1,3);
    subplot(3,3,v)
    hold on
    Y=eval(Yvar{v});
    plot(G,Y(:,Nrange),'-k.','color',col(cc))
    xlabel('L_x / L')
    ylabel([Yvar{v} ' / L_x'])
    set(gca,'yscale','log')
    axis([0 1 1e-9 1])
    box on
end    
%% max X deviation
figure(23)
clf
hold on
Nplot=[2 3 5 7];
col='kmbr';
leg={};
for n=1:numel(Nplot)
    plot(G,LIx(:,Nplot(n)),'.k-','color',col(n))
    leg{end+1}=['N=' int2str(Nplot(n))];
end
xlabel('L_x / L')
ylabel('L_\infty(\Deltax) / L_x')
set(gca,'yscale','log')
axis([0 1 1e-11 1])
box on
legend(leg)
grid on



