function catch_xdr_errors(status)
% Help function to catch the error codes from libxdrfile.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright 2014 Jon Kapla
%%
%% This file is part of xdrfile-matlab.
%%
%% xdrfile-matlab is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% xdrfile-matlab is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Lesser General Public License for more details.
%%
%% You should have received a copy of the GNU Lesser General Public License
%% along with Foobar. If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    exdr={ 'OK', 'Header', 'String', 'Double', 'Integer', 'Float', 'Unsigned integer', 'Compressed 3D coordinate',...
    'Closing file', 'Magic number', 'Not enough memory', 'End of file', 'File not found' };
    % 1) Detect the error.
    if(status && status ~= 11)

	% 2) Construct an MException object to represent the error.
	err = MException('XDRerror:Status', ...
	'Status is not OK!');
    % 3) Store any information contributing to the error
	    if(any(status==[1:10,12]))
		errCause = MException('XDRerror:Error', char(exdr(status+1)));
		err = addCause(err, errCause);
	    end
	% 4) Throw the exception to stop execution and display an error message.
	throw(err)
    end
