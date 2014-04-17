function [handle]=inittraj(file,action)
% Open a trajectory file with either libxdrfile. Returns a libpointer
% filehandle.
% 
% lib (str) - libxtc or libtrr
% file (str) - filename of xtc or trr file to open
% action (str) - r or w for read or write access
%
% Jon Kapla, 2014-04-17
    handle=calllib('libxdrfile','xdrfile_open',file,action);
end % End function
