function [status]=closetraj(handle)
% Close trajectory files
    status=calllib('libxdrfile','xdrfile_close',handle);
end % End function
