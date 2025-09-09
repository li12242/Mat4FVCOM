classdef MatFVCOM < handle
  % MATFVCOM A class for handling FVCOM data and operations.
  %   This class provides methods and properties to interact with FVCOM data,
  %   enabling users to perform various operations and analyses on FVCOM datasets.
  %
  %   The class inherits from the 'handle' class, meaning objects of this class
  %   are passed by reference.
  %

  properties
    casename % case name

    time % structure with start/end time in modified julian day

    Nv
    Ne
    Nriver
    Nsponge

    triangle_topology % vertex index of each element
    x % coordinate
    y % coordinate
    lon % coordinate in spherical
    lat % coordinate in spherical
    h % water height

    Nobc_nodes % total number of obc nodes
    open_boundary % open boundary

    % native_coords % 'carthesian' or 'spherical'

  end % properties

  methods

    % MatFVCOM Constructor for the MatFVCOM class.
    %
    % This function initializes an instance of the MatFVCOM class.
    %
    % Parameters:
    %   casename (string): The name of the case or project to be associated
    %                      with this instance of the MatFVCOM class.
    %   varargin (optional): Additional optional arguments that can be
    %                        passed to customize the initialization.
    %
    % Returns:
    %   obj: An instance of the MatFVCOM class.
    function obj = MatFVCOM(casename, varargin)
      obj.casename = casename;

      if nargin == 2

        if class(varargin{1}) == "AdcircFile14"
          obj = obj.convert_from_Adcirc14(obj, varargin{1});
        end

      else
        fprintf('Error: wrong number of input arguments!\n');
      end

    end % function

    % dump to FVCOM input files in given folder
    write_to_file(obj, input_folder)

    % transfer coordinates to carthesian
    transfer_to_carthesian(obj, lat0, lon0)

    % add sponge in specific open boundary index
    add_spong_to_open_boundary(obj, open_boundary_index, varargin)

    write_OTPS_input(obj, dt_hour)

    % write OPTS file to netcdf format
    convert_OPTS_to_netcdf(obj, filename, dt_hour)

    % smooth a vertex based field
    field = smooth_field(obj, fieldin, SmoothFactor, Niter, varargin)

    %SET_TIME Set the start and end times for the MatFVCOM object.
    %   obj = SET_TIME(obj, start_time_string, end_time_string) sets the
    %   start and end times for the object using the provided time strings.
    %   The times are converted to Modified Julian Date format.
    %
    %   Input:
    %       start_time_string - A string representing the start time.
    %       end_time_string   - A string representing the end time.
    %
    %   Output:
    %       obj - The updated MatFVCOM object with the time structure set.
    function obj = set_time(obj, start_time_string, end_time_string)
      obj.time = struct('start', [], 'end', []);
      obj.time(1).start = mjulian_time(start_time_string);
      obj.time(1).end = mjulian_time(end_time_string);
    end % function

  end % methods

  methods (Static)

    function obj = convert_from_Adcirc14(obj, adcirc_struct)
      obj.Nv = adcirc_struct.Nv;
      obj.Ne = adcirc_struct.Ne;
      obj.x = adcirc_struct.coordiantes(:, 1);
      obj.y = adcirc_struct.coordiantes(:, 2);
      obj.lon = obj.x;
      obj.lat = obj.y;
      obj.h = -adcirc_struct.bathymetry;
      obj.triangle_topology = adcirc_struct.triangle_topology;

      % define boundary struct
      obj.open_boundary = struct( ...
        'vertex', {}, 'type', {}, 'is_sponge', {}, 'radius', {}, 'coeff', {} ...
      );

      obc_node = 0;
      if isfield(adcirc_struct.boundary, 'open')
        for i = 1:numel(adcirc_struct.boundary.open)
          node_list = adcirc_struct.boundary.open{i};
          obc_node = obc_node + numel(node_list);

          obj.open_boundary(i).vertex = node_list;
          obj.open_boundary(i).type = 0; % default open boundary type
          obj.open_boundary(i).is_sponge = false; % default is sponge
          obj.open_boundary(i).radius = [];
          obj.open_boundary(i).coeff = [];
        end
      end
      obj.Nobc_nodes = obc_node;
    end % function

  end % methods

end % classdef
