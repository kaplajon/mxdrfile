classdef mxdrfile < handle
   % USAGE: traj=mxdrfile('file.trr')
   % USAGE: traj=mxdrfile('file.xtc')
   % This class creates a trajectory object with methods for reading
   % properties from a trajectory in xtc or trr format.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% This file is part of mxdrfile.
   %%
   %% Copyright © 2014 Jon Kapla. All Rights Reserved.
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
   properties
      fname;
      ftype;
      fhandle;
      natoms;
      status;
      step;
      time;
      lam;
      box;
      x;
      v;
      f;
      prec;
      ndx;
   end
   methods 
      function obj = mxdrfile(fname,ndxfilename)
          % Initialize the trajectory and read the first frame to fill all
          % possible fields.
         if nargin < 1
            error('mxdrfile:InvalidInitialization',...
               'Must provide a filename.trr or filename.xtc')
         elseif nargin ==2
	         obj.ndx=read_ndx(ndxfilename);
         end
         obj.fname=fname;
         [pathstr,fname,ext] = fileparts(obj.fname);
         if(strcmp(ext,'.xtc'))
	        [obj.status,obj.natoms]=read_xtc_natoms(obj.fname);
	     elseif(strcmp(ext,'.trr'))
            [obj.status,obj.natoms]=read_trr_natoms(obj.fname);
         else
	        error('Only .trr and .xtc supported!')
         end
         catch_xdr_errors(obj.status);
         
         %Get the XDRFILEptr object
         obj.fhandle=calllib('libxdrfile','xdrfile_open',obj.fname,'r');
         
	 % Initialize class props
         obj.ftype=ext;
         obj.step=int32(0); % Timestep
         obj.time=single(0); % Time in ps
         obj.lam=single(0); % Lambda
         b(3,3)=single(0);
         obj.box=libpointer('singlePtr',b); % Box as a 3x3 matrix
         x(3,obj.natoms)=single(0);
         obj.x=libpointer('singlePtr',x); % Coordinates as a 3xnatoms matrix
         obj.v=libpointer('singlePtr',x); % Velocities as a 3xnatoms matrix
         obj.f=libpointer('singlePtr',x); % Forces as a 3xnatoms matrix
         obj.prec=single(1000); % default XTC file precision
         %Read the first frame
         obj.read;
      end % mxdrfile
 
      function obj=read(obj)
      %Read the next frame of the trajectory   
         step=libpointer('int32Ptr',int32(0)); % Timestep
         time=libpointer('singlePtr',single(0)); % Time in ps
         lam=libpointer('singlePtr',single(0)); % Lambda
         prec=libpointer('singlePtr',single(1000)); % default XTC file precision
          if(strcmp(obj.ftype,'.trr'))
              func='read_trr';
              args={'libxdrfile',func, obj.fhandle, obj.natoms, step,...
                  time, lam, obj.box, obj.x, obj.v, obj.f};
              obj.status=calllib(args{:});
	      obj.lam=lam.value;
          elseif(strcmp(obj.ftype,'.xtc'))
              func='read_xtc';
              args={'libxdrfile',func, obj.fhandle,obj.natoms, step,...
                  time, obj.box, obj.x, prec};
              obj.status=calllib(args{:});
              obj.prec=prec.value;
          end
              % libxdrfile: read_trr() never returns exdrENDOFFILE but exdrINT instead
          if(obj.status==4 && obj.natoms~=0)
	          obj.status=11;
          end
          catch_xdr_errors(obj.status);
          obj.step=step.value;
          obj.time=time.value;
      end % read
      
      function delete(obj)
         if(strcmp(class(obj.fhandle),'lib.pointer'))
             [~,obj.fhandle]=calllib('libxdrfile','xdrfile_close',obj.fhandle);
         end
      end % delete
   end   
end % classdef
