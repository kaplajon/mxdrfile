function catch_xdr_errors(status)

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
