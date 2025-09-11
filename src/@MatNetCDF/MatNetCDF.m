classdef MatNetCDF < handle
  % MATNETCDF A class for handling NetCDF data and operations.
  %   This class provides methods and properties to interact with NetCDF data,
  %   enabling users to perform various operations and analyses on NetCDF datasets.
  %

  properties
    filepath % file path of the NetCDF file
    is_carthesian % true if the coordinates are carthesian, false if spherical
    info % structure with info of the NetCDF file

    Ntime % number of time steps
    Ne % number of elements
    Nv % number of vertices
    triangle_topology % vertex index of each element

    time % time results
    x % x coordinate
    y % y coordinate
    h % sea floor depth below geoid

    zeta % water surface elevation
    ua % Vertically Averaged x-velocity
    va % Vertically Averaged y-velocity

    wet_nodes % wet nodes
    wet_cells % wet cells

  end % properties

  methods

    % MatNetCDF Constructor for the MatNetCDF class.
    %
    % This function initializes an instance of the MatNetCDF class.
    %
    % Parameters:
    %   filepath (string): The path to the NetCDF file to be associated
    %                      with this instance of the MatNetCDF class.
    %
    % Returns:
    %   obj: An instance of the MatNetCDF class.
    function obj = MatNetCDF(filepath, is_carthesian)
      obj.filepath = filepath;
      obj.is_carthesian = is_carthesian;

      obj.info = ncinfo(obj.filepath);
      obj.get_static_data();
      obj.update_time(1);

    end % function

    function dims = update_time(obj, time_step)
      % UPDATE_TIME Update time-dependent data from the NetCDF file.
      %
      % This function reads time-dependent data such as water surface
      % elevation and velocities from the NetCDF file for a specific time step
      % and stores them in the object's properties.

      obj.zeta = ncread(obj.filepath, 'zeta', [1, time_step], [Inf, 1]);
      obj.ua = ncread(obj.filepath, 'ua', [1, time_step], [Inf, 1]);
      obj.va = ncread(obj.filepath, 'va', [1, time_step], [Inf, 1]);
      obj.wet_nodes = ncread(obj.filepath, 'wet_nodes', [1, time_step], [Inf, 1]);
      obj.wet_cells = ncread(obj.filepath, 'wet_cells', [1, time_step], [Inf, 1]);
    end % function

    function get_static_data(obj)
      % GET_STATIC_DATA Retrieve static data from the NetCDF file.
      %
      % This function reads static data such as coordinates and depth from
      % the NetCDF file and stores them in the object's properties.
      obj.time = ncread(obj.filepath, 'time');
      if obj.is_carthesian
        obj.x = ncread(obj.filepath, 'x');
        obj.y = ncread(obj.filepath, 'y');
      else
        obj.x = ncread(obj.filepath, 'lon');
        obj.y = ncread(obj.filepath, 'lat');
      end
      % obj.x = ncread(obj.filepath, 'x');
      % obj.y = ncread(obj.filepath, 'y');
      % obj.lon = ncread(obj.filepath, 'lon');
      % obj.lat = ncread(obj.filepath, 'lat');
      obj.h = ncread(obj.filepath, 'h');
      obj.triangle_topology = ncread(obj.filepath, 'nv');

      % get dimension lengths
      for i = 1:length(obj.info.Dimensions)
        dim_name = obj.info.Dimensions(i).Name;
        dim_length = obj.info.Dimensions(i).Length;

        switch dim_name
          case 'time'
            obj.Ntime = dim_length;
          case 'nele'
            obj.Ne = dim_length;
          case 'node'
            obj.Nv = dim_length;
          otherwise
            % Ignore other dimensions
        end
      end % for

    end % function

    function plot_all_zeta(obj)
      parfor i = 1:obj.Ntime
        obj.update_time(i);
        picture_name = sprintf('%s_%d.png', 'zeta', i);
        title_string = sprintf('Free Surface Elevation (m)\n%s', ...
          datestr(datenum('2024-01-01 01:00:00') + i / 24, 'yyyy-mm-dd HH:MM:SS'));
        obj.plot_tri_node(obj.zeta, title_string, picture_name);
        fprintf('Plotting time step %d/%d: %s\n', i, obj.Ntime, picture_name);
      end
    end

    function plot_tri_node(obj, var, title_string, picture_name)
      % TRI_PLOT Create a triangular plot of the specified variable.
      %
      % This function generates a triangular plot of the specified variable
      % (e.g., water surface elevation) using the object's coordinates and
      % triangle topology.

      face_alpha = ones(obj.Ne, 1) .* double(obj.wet_cells);

      figure('color', 'w')
      patch('Vertices', [obj.x, obj.y], ...
        'Faces', obj.triangle_topology, ...
        'Cdata', var, ...
        'edgecolor', 'none', ...
        'facecolor', 'interp', ...
        'FaceVertexAlphaData', face_alpha, ... % 设置面透明度数据
        'FaceAlpha', 'flat');
      grid on;
      box on;
      axis('equal', 'tight');
      xlabel('Lontitude (deg)');
      ylabel('Latitude (deg)');
      title(title_string);

      colormap(jet);
      colorbar;
      caxis([-1.5, 1.5]);

      print(picture_name, '-dpng', '-r300');
      close(gcf);

    end % function

  end % methods

end % class
