% Matlab class of FVCOM input data
classdef MatFVCOM < handle

  properties
    casename % case name

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

    native_coords % 'carthesian' or 'spherical'
  end % properties

  methods

    function obj = MatFVCOM(casename, varargin)
      obj.casename = casename;

      if nargin == 2

        if class(varargin{1}) == "AdcircFile14"
          obj = obj.convert_from_Adcirc14(obj, varargin{1});
        end

      end

    end % function

    write_to_file(obj, input_folder)
    transfer_to_carthesian(obj, lat0, lon0)
    gen_spong_radius(obj)

  end % methods

  methods (Static)

    function obj = convert_from_Adcirc14(obj, adcirc_struct)
      obj.Nv = adcirc_struct.Nv;
      obj.Ne = adcirc_struct.Ne;
      obj.x = adcirc_struct.coordiantes(:, 1);
      obj.y = adcirc_struct.coordiantes(:, 2);
      obj.lon = obj.x;
      obj.lat = obj.y;
      obj.h =- adcirc_struct.bathymetry;
      obj.triangle_topology = adcirc_struct.triangle_topology;
      % load boundary
      obj.open_boundary = struct('vertex', {}, 'type', {}, 'radius', {}, 'coeff', {});

      obc_node = 0;

      if isfield(adcirc_struct.boundary, 'open')

        for i = 1:numel(adcirc_struct.boundary.open)
          obc_node = obc_node + numel(adcirc_struct.boundary.open{i});
          node_list = adcirc_struct.boundary.open{i};
          obj.open_boundary(i).vertex = node_list;
          obj.open_boundary(i).type = 0; % default open boundary type
          obj.open_boundary(i).radius = [];
          obj.open_boundary(i).coeff = 0.001 * ones(size(node_list));
        end

      end

      obj.Nobc_nodes = obc_node;

    end % function

  end % methods

end % classdef
