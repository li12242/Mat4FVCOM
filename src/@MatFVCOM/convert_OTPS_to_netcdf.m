function convert_OTPS_to_netcdf(obj, mopts_obj, opts_file)
  % CONVERT_OPTS_TO_NETCDF Convert OPTS file to NetCDF format.
  %
  %   convert_OPTS_to_netcdf(obj, mopts_obj, pts_file) converts the specified
  %   OPTS file into a NetCDF file. This function is a method of the MatFVCOM
  %   class and is used to process and transform data from the OPTS file into
  %   a format suitable for NetCDF storage.
  %
  % :param mopts_obj: Instance of the MatOTPS object.
  % :param opts_file: Output file of OTPS.
  %
  % .. code-block:: matlab
  %
  %   obj.convert_OPTS_to_netcdf(mopts_obj, 'path/to/z.out');
  %

  % cat all boundary nodes
  obc_list = unique([obj.open_boundary(:).vertex]);
  Nobc = numel(obc_list);
  if Nobc ~= mopts_obj.Nv
    error('Number of boundary nodes in MatFVCOM (%d) does not match number in MatOTPS (%d).', ...
      Nobc, mopts_obj.Nv);
  end

  % read time and elevation
  [time, elevation] = mopts_obj.read_prediction(mopts_obj, opts_file);
  fprintf('Read time from OPTS file %d %d\n', size(time));
  fprintf('Read elevation from OPTS file %d %d\n', size(elevation));

  nc_out = struct( ...
    'ncid', [], 'dim_nboc', [], 'dim_time', [], ...
    'var_time', [], 'var_itime', [], 'var_itime2', [], 'var_obc', [], ...
    'var_iint', [], 'var_elevation', [] ...
  );
  out_file = sprintf('%s_obc.nc', obj.casename);
  nc_out.ncid = netcdf.create(out_file, 'clobber');
  nc_out = write_nc_dimension(obj, nc_out, Nobc, time);
  time = time - time(1); % make time start from 0
  write_nc_file(nc_out, obc_list, time, elevation);
  netcdf.close(nc_out.ncid);
end % function

% WRITE_NC_DIMENSION Write dimensions to a NetCDF file.
%
%   nc_out = WRITE_NC_DIMENSION(obj, nc_out, obc_nodes) writes the
%   specified dimensions to the NetCDF file represented by nc_out. This
%   function is part of the MatFVCOM class and is used to handle the
%   creation of dimensions in the NetCDF file based on the provided
%   boundary node information.
%
%   Inputs:
%       obj       - Instance of the MatFVCOM class.
%       nc_out    - NetCDF file object or structure to which dimensions
%                   will be written.
%       Nobn      - Array or list of open boundary condition (OBC) nodes
%                   used to define the dimensions in the NetCDF file.
%       mtime_vec - Array of time values in matlab datenum format.
%
%   Outputs:
%       nc_out - Updated NetCDF file object or structure with the new
%                dimensions added.
%
%   Example:
%       nc_out = obj.write_nc_dimension(nc_out, Nobn);
%
%   See also: OTHER_RELEVANT_FUNCTIONS
function nc_out = write_nc_dimension(obj, nc_out, Nobn, mtime_vec)
  % define global attributes
  netcdf.putAtt(nc_out.ncid, netcdf.getConstant('NC_GLOBAL'), ...
    'type', 'FVCOM TIME SERIES ELEVATION FORCING FILE')
  netcdf.putAtt(nc_out.ncid, netcdf.getConstant('NC_GLOBAL'), ...
    'title', obj.casename)
  netcdf.putAtt(nc_out.ncid, netcdf.getConstant('NC_GLOBAL'), ...
    'history', 'FILE CREATED using write_FVCOM_elevtide')

  % define dimensions
  nc_out.dim_nboc = netcdf.defDim(nc_out.ncid, 'nobc', Nobn); % open boundary node number
  nc_out.dim_time = netcdf.defDim(nc_out.ncid, 'time', netcdf.getConstant('NC_UNLIMITED'));
  % nc_out.dim_date_str = netcdf.defDim(nc_out.ncid, 'DateStrLen', 26);

  % define variables and attributes
  nc_out.var_obc = netcdf.defVar(nc_out.ncid, 'obc_nodes', 'NC_INT', nc_out.dim_nboc);
  netcdf.putAtt(nc_out.ncid, nc_out.var_obc, 'long_name', 'Open Boundary Node Number');
  netcdf.putAtt(nc_out.ncid, nc_out.var_obc, 'grid', 'obc_grid');

  nc_out.var_iint = netcdf.defVar(nc_out.ncid, 'iint', 'NC_INT', nc_out.dim_time);
  netcdf.putAtt(nc_out.ncid, nc_out.var_iint, 'long_name', 'internal mode iteration number');

  % time_attr = ['days since ', datestr(mtime_vec(1), 'yyyy-mm-dd HH:MM:SS')];
  time_attr = 'days since 0.0';
  nc_out.var_time = netcdf.defVar(nc_out.ncid, 'time', 'NC_FLOAT', nc_out.dim_time);
  netcdf.putAtt(nc_out.ncid, nc_out.var_time, 'long_name', 'time');
  netcdf.putAtt(nc_out.ncid, nc_out.var_time, 'units', time_attr);
  netcdf.putAtt(nc_out.ncid, nc_out.var_time, 'time_zone', 'none');

  nc_out.var_itime = netcdf.defVar(nc_out.ncid, 'Itime', 'NC_INT', nc_out.dim_time);
  netcdf.putAtt(nc_out.ncid, nc_out.var_itime, 'units', time_attr);
  netcdf.putAtt(nc_out.ncid, nc_out.var_itime, 'time_zone', 'none');
  % netcdf.putAtt(nc_out.ncid, itime_varid, 'units', 'days since 1858-11-17 00:00:00');
  % netcdf.putAtt(nc_out.ncid, itime_varid, 'format', 'modified julian day (MJD)');
  % netcdf.putAtt(nc_out.ncid, itime_varid, 'time_zone', 'UTC');

  nc_out.var_itime2 = netcdf.defVar(nc_out.ncid, 'Itime2', 'NC_INT', nc_out.dim_time);
  netcdf.putAtt(nc_out.ncid, nc_out.var_itime2, 'units', time_attr);
  netcdf.putAtt(nc_out.ncid, nc_out.var_itime2, 'time_zone', 'none');
  % netcdf.putAtt(nc_out.ncid, itime2_varid, 'units', 'msec since 00:00:00');
  % netcdf.putAtt(nc_out.ncid, itime2_varid, 'time_zone', 'UTC');

  % Times_varid = netcdf.defVar(nc_out.ncid, 'Times', 'NC_CHAR', [nc_out.dim_date_str, nc_out.dim_time]);
  % netcdf.putAtt(nc_out.ncid, Times_varid, 'time_zone', 'UTC');

  nc_out.var_elevation = netcdf.defVar(nc_out.ncid, 'elevation', 'NC_FLOAT', ...
    [nc_out.dim_nboc, nc_out.dim_time]);
  netcdf.putAtt(nc_out.ncid, nc_out.var_elevation, 'long_name', 'Open Boundary Elevation');
  netcdf.putAtt(nc_out.ncid, nc_out.var_elevation, 'units', 'meters');

  % end definitions
  netcdf.endDef(nc_out.ncid);
end % function

function write_nc_file(nc_out, obc_list, time_in_days, elevation)
  %WRITE_NC_FILE Write data to a NetCDF file.
  %
  %   This function writes the given data to a NetCDF file. It is designed
  %   to handle output related to open boundary conditions (OBC) and
  %   elevation data over a specified time period.
  %
  %   Parameters:
  %   ----------
  %   nc_out : string
  %       Path to the output NetCDF file.
  %   obc_list : array
  %       List of open boundary condition indices.
  %   time_in_days : array
  %       Time values in days corresponding to the data.
  %   elevation : array
  %       Elevation data to be written to the NetCDF file.
  %
  %   Notes:
  %   -----
  %   Ensure that the input data dimensions are consistent with the
  %   requirements of the NetCDF file structure.
  Ntime = numel(time_in_days);
  netcdf.putVar(nc_out.ncid, nc_out.var_obc, obc_list);
  netcdf.putVar(nc_out.ncid, nc_out.var_iint, 0, Ntime, 1:Ntime);
  netcdf.putVar(nc_out.ncid, nc_out.var_time, 0, Ntime, time_in_days);
  netcdf.putVar(nc_out.ncid, nc_out.var_itime, floor(time_in_days));
  netcdf.putVar(nc_out.ncid, nc_out.var_itime2, 0, Ntime, mod(time_in_days, 1) * 24 * 3600 * 1000);
  netcdf.putVar(nc_out.ncid, nc_out.var_elevation, elevation);
end % function
