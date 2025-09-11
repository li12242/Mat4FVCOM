classdef MatFVCOM < handle
  % MATFVCOM A class for handling FVCOM data and operations.
  %   This class provides methods and properties to interact with FVCOM data,
  %   enabling users to perform various operations and analyses on FVCOM datasets.
  % 

  properties
    casename % case name

    time % structure with start/end time in modified julian day

    Nv % number of vertices
    Ne % number of elements
    % Nriver % number of river

    triangle_topology % vertex index of each element
    x % coordinate
    y % coordinate
    lon % coordinate in spherical
    lat % coordinate in spherical
    h % water height

    open_boundary % open boundary

    % native_coords % 'carthesian' or 'spherical'

  end % properties

  methods

    % MatFVCOM Constructor for the MatFVCOM class.
    %
    % This function initializes an instance of the MatFVCOM class.
    %
    % :param casename: The name of the test case.
    % :param adcirc: (optional) An instance of the MatAdcirc object
    % :param fvcom: (optional) A folder containing FVCOM input files, with format of
    %               {casename}_grd.dat, {casename}_cor.dat, {casename}_obc.dat
    % :param time: (optional) A structure array with start/end time in mjulian_time
    %
    % Returns:
    %   obj: An instance of the MatFVCOM class.
    function obj = MatFVCOM(casename, varargin)
      p = inputParser;

      % parse case name
      addRequired(p, 'casename', @ischar);

      % parse input adcirc struct
      default_adcirc = [];
      addParameter(p, 'adcirc', default_adcirc, ...
        @(x)validateattributes(x, {'MatAdcirc'}, {'nonempty'}) ...
      );

      % parse fvcom input files
      default_input_folder = [];
      addParameter(p, 'fvcom', default_input_folder, @(x) isstring(x) || ischar(x));

      % parse input time
      default_time = [];
      charchk = {'mjulian_time'};
      nempty = {'nonempty'};
      addParameter(p, 'time', default_time, ...
        @(x)validateattributes(x, charchk, nempty) ...
      );

      % do the parsing
      parse(p, casename, varargin{:});

      % assign properties
      obj.casename = p.Results.casename;
      if ~isempty(p.Results.adcirc)
        obj.read_from_Adcirc(obj, p.Results.adcirc);
      end

      if ~isempty(p.Results.fvcom)
        obj.read_from_fvcom(obj, p.Results.fvcom);
      end

      if ~isempty(p.Results.time)
        obj.set_time(p.Results.time(1), p.Results.time(2));
      end

    end % function

    % dump to FVCOM input files in given folder
    write_to_file(obj, input_folder)

    % transfer coordinates to carthesian
    transfer_to_carthesian(obj, lat0, lon0)

    % add sponge in specific open boundary index
    add_spong_to_open_boundary(obj, open_boundary_index, varargin)

    % convert to OPTS object
    motps = convert_OTPS_prediction(obj, varargin)

    % write OPTS file to netcdf format
    convert_OTPS_prediction_to_netcdf(obj, mopts_obj, filename)

    function set_time(obj, start_t, end_t)
      % SET_TIME Set the start and end times for the MatFVCOM object.
      %   obj = SET_TIME(obj, start_t, end_t) sets the
      %   start and end times for the object using the mjulian_time objects.
      %
      % :param start_t: A string representing the start time.
      % :param end_t: A string representing the end time.
      % 

      % check inputs
      if (class(start_t) ~= 'mjulian_time') | (class(end_t) ~= 'mjulian_time')
        error('Start and end times must be mjulian_time object.');
      end
      obj.time = struct('start', start_t, 'end', end_t);
    end % function

  end % methods

  methods (Static)

    obj = read_from_fvcom(obj, input_dir)

    function read_from_Adcirc(obj, adcirc_struct)
      % READ_FROM_ADCIRC Convert an Adcirc structure to a MatFVCOM object.
      %   obj = READ_FROM_ADCIRC(obj, adcirc_struct) converts the given
      %   MatAdcirc object to a MatFVCOM object by mapping the relevant fields.
      %
      % :param adcirc_struct: An instance of the MatAdcirc class containing
      %                       the Adcirc data to be converted.

      if class(adcirc_struct) ~= "MatAdcirc"
        error('Input must be an instance of MatAdcirc class.');
      end
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
          obj.open_boundary(i).type = 1; % default open boundary type
          obj.open_boundary(i).is_sponge = false; % default is sponge
          obj.open_boundary(i).radius = [];
          obj.open_boundary(i).coeff = [];
        end
      end
    end % function

  end % methods

end % classdef
