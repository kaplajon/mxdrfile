function [B,title]=psfread(psffilename)
% [B,title]=psfread(psffilename)
%
% read bond matrix from psf file
%
% M.L. 2013-01-03

fid=fopen(psffilename,'r'); % open for reading
tline = fgetl(fid);
isbondblock=false;
B=[];
while ischar(tline)
    % look for end of bond block
    if(~isempty(strfind(tline,'!N')) && isempty(strfind(tline,'!NBOND')))
        isbondblock=false;
    end
     if(isbondblock)
         % read bond information
         % disp(['bond block: ' tline])
         Bfoo=str2num(tline);
         B=[B;Bfoo(1:2:end)' Bfoo(2:2:end)'];
     else
         %disp(tline)
     end
     % look for beginning of bond block
    if(~isempty(strfind(tline,'!NBOND')))
         isbondblock=true;
    end    
    
    % look for title block and read title
    if(~isempty(strfind(tline,'REMARKS system name :')))
        nc=strfind(tline,':');
        ns=strfind(tline,' '); 
        nt=1+ns(find(ns>nc,1)); % title starts at first non-space char after first :
        title=tline(nt:end);
        while(strcmp(title(end),' ')) % shave off trailing spaces
            title=title(1:end-1);
        end
        clear nt nc ns
    end
    
    tline = fgetl(fid);
end


