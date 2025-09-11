function obj = read_from_fvcom(obj, input_dir)
  % READ_FROM_FVCOM Read FVCOM model output files and populate the MatFVCOM object.
  %   obj = READ_FROM_FVCOM(obj, input_dir) reads the necessary FVCOM
  %   model output files from the specified input directory and populates
  %   the properties of the MatFVCOM object.
  %
  % :param input_dir: A string representing the directory containing the FVCOM
  %   model output files.
  % :return: The populated MatFVCOM object.

  % check input directory
  if ~isfolder(input_dir)
    error('Input directory does not exist.');
  end

  casename = obj.casename;

  % read grid file
  [obj.x, obj.y, obj.h, obj.triangle_topology] = read_fvcom_grid_file( ...
    [input_dir, filesep, casename, '_grd.dat'] ...
  );
  % read cor file
  obj.lat = read_fvcom_cor_file([input_dir, filesep, casename, '_cor.dat']);

  obj.Nv = length(obj.x);
  obj.Ne = size(obj.triangle_topology, 1);

  % read obc file
  obj.open_boundary = read_fvcom_obc_file([input_dir, filesep, casename, '_obc.dat']);

  % % read sponge parameters if exist
  % sponge_file = [input_dir, filesep, casename, '_spg.dat'];
  % if ~isfile(sponge_file)
  %   warning('Sponge file does not exist: %s. Skip reading sponge parameters.', sponge_file);
  %   return;
  % end

end % function

function [x, y, h, triangle_topology] = read_fvcom_grid_file(grid_file)
  % READ_FVCOM_GRID_FILE Read FVCOM grid file and extract node coordinates, depth, and triangle topology.
  %   [x, y, h, triangle_topology] = READ_FVCOM_GRID_FILE(grid_file) reads the
  %   specified FVCOM grid file and extracts the node coordinates (x, y),
  %   depth (h), and triangle topology.
  %
  % :param grid_file: A string representing the path to the FVCOM grid file.
  % :return: x - A vector of x-coordinates of the nodes.
  %          y - A vector of y-coordinates of the nodes.
  %          h - A vector of depths at the nodes.
  %          triangle_topology - A matrix representing the triangle topology.
  if ~isfile(grid_file)
    error('Grid file does not exist: %s', grid_file);
  end

  file_h = fopen(grid_file, 'r');

  % read numbers
  node_line = fgetl(file_h);
  Nv = sscanf(node_line, 'Node Number = %d');
  cell_line = fgetl(file_h);
  Ne = sscanf(cell_line, 'Cell Number = %d');

  triangle_topology = zeros(Ne, 3);
  data = fscanf(file_h, '%d %d %d %d %d\n', [5, Ne]);
  triangle_topology(1:Ne, :) = data(2:4, 1:Ne)';

  data = fscanf(file_h, '%d %f %f %f\n', [4, Nv]);
  x = data(2, :)';
  y = data(3, :)';
  h = data(4, :)';

  fclose(file_h);
end

function lat = read_fvcom_cor_file(cor_file)
  % READ_FVCOM_COR_FILE Read FVCOM Cor file and extract Coriolis parameter.
  %   READ_FVCOM_COR_FILE(obj, cor_file) reads the specified FVCOM Cor file
  %   and extracts the Coriolis parameter, populating the corresponding
  %   property in the MatFVCOM object.
  %
  % :param cor_file: A string representing the path to the FVCOM Cor file.

  if ~isfile(cor_file)
    error('Cor file does not exist: %s', cor_file);
  end

  file_h = fopen(cor_file, 'r');

  % read numbers
  node_line = fgetl(file_h);
  Nv = sscanf(node_line, 'Node Number = %d');

  data = fscanf(file_h, '%f %f %f\n', [3, Nv]);
  lat = data(3, :)';

  fclose(file_h);
end

function open_boundary = read_fvcom_obc_file(obc_file)
  % READ_FVCOM_OBC_FILE Read FVCOM open boundary condition file and extract boundary information.
  %   READ_FVCOM_OBC_FILE(obj, obc_file) reads the specified FVCOM open
  %   boundary condition file and extracts the boundary information,
  %   populating the corresponding property in the MatFVCOM object.
  %
  % :param obc_file: A string representing the path to the FVCOM open boundary condition file.

  if ~isfile(obc_file)
    error('OBC file does not exist: %s', obc_file);
  end

  file_h = fopen(obc_file, 'r');

  % read numbers
  obc_line = fgetl(file_h);
  Nobc = sscanf(obc_line, 'OBC Node Number = %d');

  data = fscanf(file_h, '%d %d %d\n', [3, Nobc]);
  obc_type = unique(data(3, :));
  obc_type_num = length(obc_type);

  % initialize open_boundary struct array
  open_boundary = struct( ...
    'vertex', {}, 'type', {}, 'is_sponge', {}, 'radius', {}, 'coeff', {} ...
  );

  for i = 1:obc_type_num
    open_boundary(i).type = obc_type(i);
    ind = (data(3, :) == obc_type(i));
    open_boundary(i).vertex = data(2, ind)';
  end

  fclose(file_h);
end

% function [] = read_fvcom_spg_file(file)
%   % READ_FVCOM_SPG_FILE Read FVCOM sponge layer file and extract sponge parameters.
%   %   READ_FVCOM_SPG_FILE(obj, spg_file) reads the specified FVCOM sponge
%   %   layer file and extracts the sponge parameters, populating the
%   %   corresponding properties in the MatFVCOM object.
%   %
%   % :param spg_file: A string representing the path to the FVCOM sponge layer file.

%   if ~isfile(file)
%     error('Sponge file does not exist: %s', file);
%   end

%   file_h = fopen(file, 'r');

%   % read numbers
%   obc_line = fgetl(file_h);
%   Nobc = sscanf(obc_line, 'OBC Node Number = %d');

%   data = fscanf(file_h, '%d %f %f\n', [3, Nobc]);

%   fclose(file_h);
% end
