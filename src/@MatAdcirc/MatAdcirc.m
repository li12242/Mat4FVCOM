classdef MatAdcirc < handle
  % ADCIRCF14 Class for handling ADCIRC fort.14 files
  %
  % This class is designed to manage and manipulate ADCIRC
  % fort.14 files, which contain grid and boundary condition information
  % for ADCIRC simulations.
  %
  properties (SetAccess = private)
    Nv % number of vertex
    Ne % number of element
    coordiantes % vertex coordinates
    bathymetry % bathymetry elevation at vertex
    triangle_topology % vertex index in each triangle element
    boundary % structure with two fields: open and land each field is a
    % cell array, each cell contains a vector of vertex indices
  end

  methods

    % MatAdcirc Constructor
    %
    % This function initializes an instance of the MatAdcirc class.
    %
    % :param filename: The path to the ADCIRC file (fort.14) to be loaded.
    %
    function obj = MatAdcirc(varargin)
      if nargin == 1
        filename = varargin{1};
        obj = obj.read_fort14(obj, filename);
      end
    end

    % plot boundaries on spicific axes
    plot_boundary(obj, h_axe)
  end

  methods (Static)
    function obj = read_fort14(obj, filename)
      % READ_FORT14 Read ADCIRC fort.14 file
      % This function reads an ADCIRC fort.14 file and populates the
      % properties of the MatAdcirc object.
      %
      % :param filename: The path to the ADCIRC fort.14 file to be read.
      %

      % open file handle
      file_h = fopen(filename, 'r');
      fgetl(file_h); % jump first line
      %% read vertex and element num
      line = fgetl(file_h);
      data = sscanf(line, '%d %d');
      obj.Ne = data(1);
      obj.Nv = data(2);

      %% read vertex coordinates and bathymetry
      coordinates = fscanf(file_h, '%d %f %f %f\n', [4, obj.Nv]);
      coordinates = coordinates';

      obj.coordiantes = coordinates(:, [2, 3]);
      obj.bathymetry = coordinates(:, 4);

      %% read mesh topology of triangle elements
      tri_topology = fscanf(file_h, '%d %d %d %d %d\n', [5, obj.Ne]);
      tri_topology = tri_topology';
      obj.triangle_topology = tri_topology(:, [3, 4, 5]);

      %% read boundary
      obj.boundary = obj.read_boundary(obj, file_h);
      fclose(file_h);
    end

    function boundary_cell = read_boundary_index(Nb, file_h)
      % READ_BOUNDARY_INDEX Read boundary indices from ADCIRC fort.14 file
      % This function reads boundary indices from an ADCIRC fort.14 file
      % and returns them as a cell array.
      %
      % :param Nb: The number of boundaries to read.
      % :param file_h: The file handle of the opened ADCIRC fort.14 file.
      % :return: A cell array where each cell contains a vector of boundary
      %          vertex indices.
      %
      boundary_cell = cell(Nb, 1);
      fgetl(file_h); % jump total point number

      for i = 1:Nb
        line = fgetl(file_h);
        Nbp = sscanf(line, '%d', 1);
        boundary_cell{i} = fscanf(file_h, '%d\n', [Nbp, 1]);
      end

    end

    function boundary = read_boundary(obj, file_h)
      % READ_BOUNDARY Read boundary conditions from ADCIRC fort.14 file
      % This function reads the boundary conditions from an ADCIRC fort.14 file
      % and returns a structure containing open and land boundaries.
      %
      % :param file_h: The file handle of the opened ADCIRC fort.14 file.
      % :return: A structure with two fields: `open` and `land`, each containing
      %          a cell array of boundary vertex indices.
      %
      boundary = struct('open', {}, 'land', {});

      while ~feof(file_h)
        line = fgetl(file_h);
        Nb = sscanf(line, '%d', 1);

        if contains(line, 'open')
          boundary(1).open = obj.read_boundary_index(Nb, file_h);
        end

        if contains(line, 'land')
          boundary(1).land = obj.read_boundary_index(Nb, file_h);
        end
      end

    end

  end

end
