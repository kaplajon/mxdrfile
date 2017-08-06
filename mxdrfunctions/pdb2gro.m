function pdb2gro(grofile,a,sysname,t0,aw)
% pdb2gro(grofile,a,sysname,t0,aw)
%
% convert a pdb structure to gromacs gro-format, with zero velocities
% 
% grofile   filename of grofile to create. If existing, the file is
%           overwritten.
% a         Matlab pdb structure
% sysname   string with name of system, to match the corresponding 
%           [ system ] entry in the .top file
% t0        (optional) time in ps (default 0)
% aw        argument to fopen (default 'w')

if(~exist('t0','var')|| isempty(t0))
    t0=0;
end
if(~exist('aw','var'))
    aw='w';
end

fid=fopen(grofile,aw); % open and overwrite

% title string (free format string, optional time in ps after 't=')
fprintf(fid,'%s t= %f\n',sysname,t0);
%fprintf('%s t= %f\n',sysname,t0);

% number of atoms (free format integer)
N=length(a.Model.Atom);
fprintf(fid,'%5d\n',N);
%fprintf('%5d\n',N);

% one line for each atom (fixed format, see below)
% Note: pdb uses Å, while .gro uses nm
for k=1:N
    resNum=a.Model.Atom(k).resSeq;
    res=a.Model.Atom(k).resName;
    aName=a.Model.Atom(k).AtomName;
    aNum=a.Model.Atom(k).AtomSerNo;
    x=a.Model.Atom(k).X/10;
    y=a.Model.Atom(k).Y/10;
    z=a.Model.Atom(k).Z/10;
    vx=0;vy=0;vz=0;
    
    fprintf(fid,'%5d%-5s%5s%5d%8.3f%8.3f%8.3f%8.4f%8.4f%8.4f\n',...
        resNum,res,aName,mod(aNum,1e5),x,y,z,vx,vy,vz);
    
    % new, from gromacs manual, with spaces in strings
    %fprintf(fid,'%5d%-5s%5s%5d%8.3f%8.3f%8.3f%8.4f%8.4f%8.4f\n',...
    %    resNum,res,aName,aNum,x,y,z,vx,vy,vz);

end

% box vectors (free format, space separated reals), values: v1(x) v2(y) v3(z) v1(y) v1(z) v2(x) v2(z) v3(x) v3(y), the last 6 values may be omitted (they will be set to zero). Gromacs only supports boxes with v1(y)=v1(z)=v2(z)=0. 
% Here, a rectangular box with 
fprintf(fid,'%f %f %f\n',a.Cryst1.a/10,a.Cryst1.b/10,a.Cryst1.c/10);
%fprintf('%f %f %f\n',    a.Cryst1.a/10,a.Cryst1.b/10,a.Cryst1.c/10);

fclose(fid);
