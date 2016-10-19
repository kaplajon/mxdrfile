loadmxdrfile; % Load the xdrfile library
% open file and read the first frame
trj=mxdrfile('test.xtc');
z=[];
% Loop over the trajectory frames
while(~trj.status)
    z(end+1)=mean(trj.x.value(3,:));
    trj.read(); % read next frame
end
clear trj

