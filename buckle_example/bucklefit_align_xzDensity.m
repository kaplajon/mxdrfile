% a script example to illustrate the buckling analysis and produce some 
% xz-density plots.
% ML 2016-06-13x

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

%% paths and parameters
clear

% add paths
% mxdrfile
d0=pwd;
cd ..
loadmxdrfile
cd(d0)
addpath buckleanalysis/
format compact

% figure production
xtcIn='magainin1_compact/solvated_0.2_eq2.xtc';
ndxFile='magainin1_compact/index_analysis.ndx';

% shorter trajectory for testrunning the example
xtcIn='magainin1_compact2/nowater_eq2_0.80.xtc';
ndxFile='magainin1_compact2/nowater_eq2_0.80.ndx';

xtcOutfile='aligned.xtc';
savefile  ='bucklefit.mat';

disp('xtc input file:')
ls(xtcIn)
disp('ndx file:')
ls(ndxFile)

xcFactorInit=0.8; % initial guess for compression factor
writeXtc=true;
plotFit=false;
nFit=500;
nx=150;
nz=round(14.1/20.9*nx);
% parse index file
M=read_ndx(ndxFile);%ndxRead(ndxFile);

% inner tail beads of lipids for fitting and alignment
iFit0=[M.POPG(8:13:end); ...
      M.POPG(13:13:end); ...
      M.POPE(8:13:end) ; ...
      M.POPE(13:13:end)];

iWrite=[M.Protein; M.POPG; M.POPE; M.ION];
  
indP=M.Protein;
indPsub1=indP;
indH=[M.POPG(2:13:end); M.POPE(2:13:end)];

% index for density histograms
iDens={};
iDens{end+1}=M.POPG;
iDens{end+1}=M.POPE;
iDens{end+1}=M.ION;
iDens{end+1}=M.Protein;
titleDens={'POPG','POPE','ions','peptide'};

%clear M
%% start analysis
[~,rTraj]=inittraj(xtcIn,'r');

% read some box info
[~,traj]=read_xtc(rTraj);
Lx=double(traj.box.value(1,1));
Ly=double(traj.box.value(2,2));
Lz=double(traj.box.value(3,3));
% close and reopen to reset lines
[~,~]=closetraj(rTraj);
[~,rTraj]=inittraj(xtcIn,'r');

frame=0;

% aligned output
if(writeXtc)
    [~,wTraj]=inittraj(xtcOutfile,'w');
end
XZGSVE=[];
%% prepare histograms
E={linspace(0,Lx,nx+1),linspace(0,Lz,nz+1)};
C=cell(1,2);
for h=1:2
    C{h}=(E{h}(1:end-1)+E{h}(2:end))/2;
end
for h=1:numel(iDens)
   cDens{h}=zeros(nz,nx); 
end
sRows=floor(sqrt(numel(iDens)));
sCols=ceil(numel(iDens)/sRows);
figure(2)
clf
for h=1:numel(iDens)
   subplot(sRows,sCols,h)
   hold on
   set(gca,'ydir','normal');
   hDens(h)=imagesc(C{1},C{2},cDens{h});
   axis equal
   axis tight
   %axis off
   title(titleDens{h})
end
colormap gray
%% prepare plots
if(plotFit)
    figure(1)
    clf
    hold on
    axis equal
    view(0,0)
    box on
    grid on
    xlabel('x')
    zlabel('z')
    % configuration plots
    datH=plot3(1,1,1,'r.','markersize',1); % lipid heads
    datT2=plot3(1,1,1,'k.','markersize',1);% lipid tail2s
    datS=plot3(1,1,1,'c.','markersize',3); % projected lipid tail positions
    
    datP=plot3(1,1,1,'-g.','markerface','none','markersize',5,'linew',2);
    
    datPn=plot3(1,1,1,'k-','linew',2);
    datPt=plot3(1,1,1,'k-','linew',2);
    datPy=plot3(1,1,1,'k-','linew',2);
    datPu=plot3(1,1,1,'b-','linew',3);
    
    axis([-5 5+Lx -5 5+Ly 0 Lz])
end
sBin=linspace(0,1,101);
sBin=0.5*(sBin(1:end-1)+sBin(2:end));
NS=0*sBin;
vBin=linspace(-1,1,51);
vBin=0.5*(vBin(1:end-1)+vBin(2:end));
NV=0*vBin;
axis([-1 Lx+1 -1 Ly+1 -1 Lz+1])
%% analysis loop
tic
while true % Frameloop
    [rstatus,traj]=read_xtc(rTraj);
    if(~rstatus)
        frame=frame+1;
    else
        break
    end
    %% fit buckled shape
    % positions to fit to
    Xf = double(traj.x.value(1,iFit0))';
    Yf = double(traj.x.value(2,iFit0))';
    Zf = double(traj.x.value(3,iFit0))';   
    % if no old guess is available, fit a sine first
    if(frame==1)
        pp_old=[mean(Zf) Lx/2 max(Zf)-min(Zf)];
        ff=@(p,x)(p(1)+p(3)*(-cos( 2*pi*(x-p(2))/Lx)));
        pp=lsqcurvefit(ff,pp_old,Xf,Zf);
        % construct an initial guess for buckling fit
        x0=pp(2);
        z0=pp(1);
        if(pp(3)<0) % then inverted
            x0=mod(x0+Lx/2,Lx);
            z0=z0-2*pp(3);
        end
    else
       x0=xzg2(1); 
       z0=xzg2(2);
    end
    s0=(Xf-x0)/Lx;  % projected positions (rough guess)
    % fit to real buckled shape
    iFit=randperm(numel(iFit0));
    iFit=iFit(1:nFit);
    q0=[x0;z0;xcFactorInit;s0(iFit)];
    [xzg2,ss2,xx2,zz2]=fit_min2D_buckle(q0(1:3),q0(4:end),Xf(iFit),Zf(iFit),Lx);
    yy2=Yf(iFit);
    xzg2(1)=mod(xzg2(1),Lx); 
    % average fit error
    dxz=[Xf(iFit)-xx2 Zf(iFit)-zz2];
    rmsXZ=sqrt(mean(sum(dxz.^2,2))); % RMS fit error
    
    fprintf('%s : frame %5d , %6.2f s, rms %6.2f\n',savefile,frame,toc,rmsXZ);
    tic
        
    % offset positions and extract protein position
    % the whole protein
    Xp=double(traj.x.value(1,indP));
    Yp=double(traj.x.value(2,indP));
    Zp=double(traj.x.value(3,indP));
    
    [xi,zi]=buckleshape_Fcoeff_lin(0.25,xzg2(3),Lx);
    dx=xzg2(1);
    dy=(Yp(1)-Ly/2);
    dz=(xzg2(2)+zi-Lz/2);
    
    traj.x.value(1,:)=mod(traj.x.value(1,:)-dx,Lx);
    % protein in the middle of the patch
    traj.x.value(2,:)=mod(traj.x.value(2,:)-dy,Ly);
    % membrane inflection point at z=Lz/2
    traj.x.value(3,:)=mod(traj.x.value(3,:)-dz,Lz);
    %% plot alignment of the present frame
    if(plotFit)        
        set(datH,'xdata',mod(traj.x.Value(1,indH),Lx),...
            'ydata',traj.x.Value(2,indH),...
            'zdata',traj.x.Value(3,indH))
        set(datT2,'xdata',mod(Xf-dx,Lx),'ydata',Yf-dy,'zdata',Zf-dz)
        set(datS,'xdata',mod(xx2-dx,Lx),'ydata',yy2-dy,'zdata',zz2-dz)
        
        set(datP,'xdata',mod(Xp-dx,Lx),'ydata',Yp-dy,'zdata',Zp-dz)
        
        drawnow
        pause(0.01)
    end
    %% write aligned trajectory to disk
    if(writeXtc)
        % traj is a pointer, so one cannot make a backup copy of it
        x0=traj.x.value;
        na0=traj.natoms;        
        traj.x.value=traj.x.value(:,iWrite);
        traj.natoms=numel(iWrite);
        wstatus=write_xtc(wTraj, traj);
        traj.x.value=x0;
        traj.natoms=na0;
    end
    %% save fit data
    XZGE(frame,:)=[xzg2' rmsXZ];
    if(mod(frame,200)==0)
       save(savefile)
       disp(['saved intermediate at frame ' int2str(frame) ' : ' savefile])
    end
    %% add to histogram
    for h=1:numel(iDens)
        xh=traj.x.value(1,iDens{h})';
        zh=traj.x.value(3,iDens{h})';
        [a,b]=hist3([xh zh],C);
        cDens{h}=cDens{h}+a'/sum(a(:));
        set(hDens(h),'cdata',-cDens{h})
        %set(hCoord(h),'xdata',xh,'ydata',zh)
    end
    pause(0.01)
end
save(savefile,'XZGSVE')
[status,rTraj]=closetraj(rTraj);
if(writeXtc)
    [status,wTraj]=closetraj(wTraj);
end
