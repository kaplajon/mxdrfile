function [status]=closetraj(init)
% Close xdrfile trajectory files
% initstruct - from inittraj()
%
% Jon Kapla, 2014-04-22
    status=calllib('libxdrfile','xdrfile_close',init.fhandle);
    catch_xdr_errors(status);
end % End function
