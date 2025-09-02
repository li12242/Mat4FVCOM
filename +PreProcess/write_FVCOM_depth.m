function write_FVCOM_depth(Mobj,casename) 
% Write bathymetry to FVCOM format depth file .e.g test_dep.dat
%
% function write_FVCOM_depth(Mobj,filename)
%
% DESCRIPTION:
%    Generate an ascii FVCOM 3.x format depth from Mesh object
%
% INPUT 
%   Mobj     = Mesh object
%   casename = FVCOM case name
%
% OUTPUT:
%    FVCOM depth file: filename
%
% EXAMPLE USAGE
%    write_FVCOM_depth(Mobj,'tst')   
%
% Author(s):  
%    li12242 (Tianjin University)
%
% Revision history
%    2014_11_29, modified input parameter[change 'filename' => casename]
%   
%==============================================================================
subname = 'write_FVCOM_depth';
global ftbverbose
if(ftbverbose)
  fprintf('\n'); fprintf(['begin : ' subname '\n']);
end
filename = [casename, '_dep.dat'];

%------------------------------------------------------------------------------
% Dump the file
%------------------------------------------------------------------------------
if(lower(Mobj.nativeCoords(1:3)) == 'car')
	x = Mobj.x;
	y = Mobj.y;
else
	x = Mobj.lon;
	y = Mobj.lat;
end
if(Mobj.have_bath)
	if(ftbverbose); fprintf('writing FVCOM bathymetry file %s\n',filename); end
	fid = fopen(filename,'w');
	fprintf(fid,'Node Number = %d\n',Mobj.nVerts);
	for i=1:Mobj.nVerts
	  fprintf(fid,'%f %f %f\n',x(i),y(i),Mobj.h(i));
	end
	fclose(fid);
else
	error('can''t write bathymetry to file, mesh object has no bathymetry')
end

if(ftbverbose)
  fprintf(['end   : ' subname '\n'])
end


