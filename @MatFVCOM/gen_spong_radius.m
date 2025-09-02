% Generate a variable sponge radius based on distance to the boundary
% node's furthest neighbour.
% (Adapted from Phil Hall's 'produce_netcdf_input_data.py')
%
% spongeRadius = calc_sponge_radius(obj,Nlist)
%
% DESCRIPTION
%    Calculates the sponge radius for each node on the open boundary, based
%    on the minimum of either the distance to the node's furthest
%    neighbour, or 100 km.
%
% INPUT
%    obj = Matlab mesh object
%    Nlist = List of nodes
%
% OUTPUT
%    spongeRadius = List of variable sponge radii
%
% EXAMPLE USAGE
%    spongeRadius = calc_sponge_radius(obj,Nlist)
%
% Author(s)
%    Karen Thurston (National Oceanography Centre, Liverpool)
%
%==========================================================================
function gen_spong_radius(obj)

  for k = 1:numel(obj.open_boundary)
    verex_list = obj.open_boundary(k).vertex;
    spong_radius = 100000 + zeros(size(verex_list));

    % calculate each spong radius at vertex
    for i = 1:length(verex_list)
      [tri_list, ~] = find(obj.triangle_topology == verex_list(i));

      % find adjacent vertex
      neighbours = unique(obj.triangle_topology(tri_list, :));
      n = (neighbours ~= verex_list(i));
      neighbours = neighbours(n);

      % calculate the arc length (in degrees) between the node and its
      % neighbours
      arclen = distance(obj.lat(verex_list(i)), obj.lon(verex_list(i)), ...
        obj.lat(neighbours), obj.lon(neighbours));
      arclen = ceil(1000 * deg2km(arclen));

      if min(arclen) < spong_radius(i)
        spong_radius(i) = min(arclen);
      end

    end % for

    obj.open_boundary(k).radius = spong_radius;

  end % for

end % function
