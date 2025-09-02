function Mobj = read_ADCIRC_cartesian_mesh(filepath)
% Read sms mesh files into Matlab mesh object
%
% DESCRIPTION:
%    Read ADCIRC bathymetry file 
%    Store in matlab mesh object
%
% INPUT [keyword pairs]:  
%   filepath    - path to ADCIRC bathymetry file, .e.g 'samples/fort.14'
%
% OUTPUT: Mobj properties, include
%   x       - coordinate
%   y       - coordinate
%   lon     - same as x
%   lat     - same as y
%   h       - mesh depth
%   tri     - element to vertice, size [nElement x 3] (for triangle only)
%   
% EXAMPLE USAGE
%    Mobj = read_sms_mesh('samples/fort.14','coor','coordinate','project',true)
%
% Author:  
%    li12242
%
% Email:
%    li12242@tju.edu.cn
%   
%==============================================================================


%------------------------------------------------------------------------------
% Create a blank mesh object
%------------------------------------------------------------------------------
Mobj = FVCOM.Mesh.make_blank_mesh();
coordinate = 'cartesian';
		
%------------------------------------------------------------------------------
% Read the mesh from the fort14 file
%------------------------------------------------------------------------------

mesh = AdcircFile14(filepath);
x = mesh.PointPositionXY(:,1); y = mesh.PointPositionXY(:,2);
have_xy = true;
%------------------------------------------------------------------------------
% Project if desired by user
%------------------------------------------------------------------------------

[lon,lat] = FVCOM.PreProcess.my_project(x,y,'inverse');

%------------------------------------------------------------------------------
% Transfer to Mesh structure
%------------------------------------------------------------------------------

Mobj.nVerts  = mesh.Nv;
Mobj.nElems  = mesh.Ne;
Mobj.nativeCoords = coordinate;

Mobj.have_xy        = have_xy;

Mobj.x            = x;
Mobj.y            = y;
Mobj.ts           = nan;
Mobj.lon          = lon;
Mobj.lat          = lat;
Mobj.h            = mesh.depth;
Mobj.tri          = mesh.triangle_topology;
Mobj.have_bath  = true;
%------------------------------------------------------------------------------
% write Boundary to Mesh structure
%------------------------------------------------------------------------------
Mobj.nObs         = numel(mesh.OpenBoundarySerial_cell);
Mobj.obc_nodes    = cell(Mobj.nObs,1);

plotFig = 0; ObcType = 1; ObcName = 'Open_Boundary';
for i = 1:Mobj.nObs
    Obcser = i;
    Mobj  = FVCOM.PreProcess.add_obc_nodes_list...
        (Mobj,mesh.OpenBoundarySerial_cell{i},...
        Obcser,ObcName,ObcType,plotFig);
end% for 
end% funciton