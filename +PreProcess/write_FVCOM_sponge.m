function write_FVCOM_sponge(Mobj,casename) 

% Write FVCOM format sponge layer file  .e.g spg.dat
%
% function write_FVCOM_sponge(Mobj,filename)
%
% DESCRIPTION:
%    Generate an ascii FVCOM 3.x format sponge file from Mesh object
%
% INPUT 
%   Mobj     = Mesh object
%   filename = FVCOM sponge file name
%
% OUTPUT:
%    FVCOM sponge file: filename
%
% EXAMPLE USAGE
%    write_FVCOM_sponge(Mobj,'tst')   
%
% Author(s):  
%    Geoff Cowles (University of Massachusetts Dartmouth)
%    Karen Thurston (National Oceanography Centre, Liverpool)
%
% Revision history
%   2013-01-18  Added support for variable sponge radius
%   
%==============================================================================
subname = 'write_FVCOM_sponge';
global ftbverbose 
if(ftbverbose)
  fprintf('\n'); fprintf(['begin : ' subname '\n']);
end
filename = [casename, '_spg.dat'];

%------------------------------------------------------------------------------
% Dump the file
%------------------------------------------------------------------------------
if(ftbverbose); fprintf('writing FVCOM spongefile %s\n',filename); end
fid = fopen(filename,'w');

if(Mobj.nSponge==0)
	fprintf(fid,'Sponge Node Number = %d\n',0);
else
	Total_Sponge = sum(Mobj.nSpongeNodes(1:Mobj.nSponge));
	fprintf(fid,'Sponge Node Number = %d\n',Total_Sponge);
	for i=1:Mobj.nSponge
        % if you have a variable sponge radius
        for j=1:Mobj.nSpongeNodes(i)
            fprintf(fid,'%d %f %f \n',Mobj.sponge_nodes{i}(j),Mobj.sponge_rad{i}(j),Mobj.sponge_fac(i));
        end
	end
end
fclose(fid);
		
if(ftbverbose)
  fprintf(['end   : ' subname '\n'])
end

