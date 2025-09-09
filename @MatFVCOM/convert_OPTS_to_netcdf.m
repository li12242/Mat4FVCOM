% CONVERT_OPTS_TO_NETCDF Convert OPTS file to NetCDF format.
%
%   convert_OPTS_to_netcdf(obj, opts_file, dt_hour) converts the specified
%   OPTS file into a NetCDF file. This function is a method of the MatFVCOM
%   class and is used to process and transform data from the OPTS file into
%   a format suitable for NetCDF storage.
%
%   Inputs:
%       obj       - Instance of the MatFVCOM class.
%       opts_file - Path to the OPTS file to be converted.
%       dt_hour   - Time interval in hours for the data processing.
%
%   Outputs:
%       None. The function performs the conversion and saves the resulting
%       NetCDF file to the appropriate location.
%
%   Example:
%       obj.convert_OPTS_to_netcdf('path/to/opts_file.opts', 1);
%
%   See also: OTHER_RELEVANT_FUNCTIONS
function convert_OPTS_to_netcdf(obj, opts_file, dt_hour)

  % cat all boundary nodes
  obc_list = [];
  for i = 1:numel(obj.open_boundary)
    obc_list = [obc_list, obj.open_boundary(i).vertex(:)'];
  end % for
  Nobc = numel(obc_list);

  % read time and elevation
  time = read_OPTS_time(opts_file, Nobc, dt_hour);
  elevation = read_OPTS_elevation(opts_file, obc_list, time);
  Ntime = numel(time);

  nc_out = struct( ...
    'ncid', [], 'dim_nboc', [], 'dim_time', [], ...
    'var_time', [], 'var_itime', [], 'var_itime2', [], 'var_obc', [], ...
    'var_iint', [], 'var_elevation', [] ...
  );
  output_name = sprintf('%s_obc.nc', obj.casename);
  nc_out.ncid = netcdf.create(output_name, 'clobber');
  nc_out = write_nc_dimension(obj, nc_out, Nobc)
  write_nc_file(nc_out, obc_list, time, elevation);
  netcdf.close(nc_out.ncid);
end % function

% READ_OPTS_TIME Reads time information from an OPTS file.
%
% Syntax:
%   time = read_OPTS_time(opts_file, Nobc, dt_hour)
%
% Description:
%   This function extracts time-related data from the specified OPTS file.
%   It processes the file based on the number of open boundary conditions
%   (Nobc) and the time step in hours (dt_hour).
%
% Inputs:
%   opts_file - String specifying the path to the OPTS file.
%   Nobc      - Integer representing the number of open boundary conditions.
%   dt_hour   - Numeric value specifying the time step in hours.
%
% Outputs:
%   time - Array containing the extracted time data.
%
% Example:
%   time = read_OPTS_time('path/to/opts_file', 3, 1.0);
%
% See also:
%   Other related functions or references.
function time = read_OPTS_time(opts_file, Nobc, dt_hour)
  % count time steps
  file_h = fopen(opts_file, 'r');
  for i = 1:6
    fgetl(file_h); % skip the header line
  end % for
  nline = 0;
  while ~feof(file_h)
    fgetl(file_h); % skip the position line
    nline = nline + 1;
  end % while
  ntime = nline / Nobc - 1;
  fprintf('Total line %d, boundary node num %d, time steps: %d\n', ...
    nline, Nobc, ntime);

  % generate time array
  dt_day = dt_hour / 24;
  time = 0:dt_day:(ntime - 1) * dt_day;
end % function

%READ_OPTS_ELEVATION Read elevation data from an OPTS file.
%
%   elevation = READ_OPTS_ELEVATION(opts_file, obc_list, time) reads the
%   elevation data from the specified OPTS file for the given open boundary
%   condition (OBC) list and time.
%
%   INPUT:
%       opts_file - Path to the OPTS file containing elevation data.
%       obc_list  - List of open boundary condition indices to extract data for.
%       time      - Time step or timestamp for which elevation data is required.
%
%   OUTPUT:
%       elevation - Extracted elevation data corresponding to the specified
%                   OBC list and time.
%
%       /mnt/beegfs/lilongxiang/project/pr-fvcom/software/Mat4FVCOM/@MatFVCOM/convert_OPTS_to_netcdf.m
function elevation = read_OPTS_elevation(opts_file, obc_list, time)
  Nobc = numel(obc_list);
  Ntime = numel(time);
  elevation = zeros(Ntime, Nobc);

  % open the OPTS output file
  file_h = fopen(opts_file, 'r');
  for i = 1:6
    fgetl(file_h); % skip the header line
  end % for

  for k = 1:numel(obc_list)
    fgetl(file_h); % skip the position line
    % line = fgetl(file_h);
    % fprintf('read position for node %d: %s\n', k, line);

    % read elevation
    data = fscanf(file_h, '%d.%d.%d %d:%d:%d %f %f\n', [8, Ntime]);
    % fprintf('data = %d.%d.%d %d:%d:%d %f %f\n', data)
    fprintf('Read %d time steps for node %d\n', size(data, 2), k);
    elevation(:, k) = data(7, :); % second column is elevation
  end % for

  fclose(file_h);

  elevation = elevation'; % transpose to (Nobc, Ntime)
end

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
%       obc_nodes - Array or list of open boundary condition (OBC) nodes
%                   used to define the dimensions in the NetCDF file.
%
%   Outputs:
%       nc_out - Updated NetCDF file object or structure with the new
%                dimensions added.
%
%   Example:
%       nc_out = obj.write_nc_dimension(nc_out, obc_nodes);
%
%   See also: OTHER_RELEVANT_FUNCTIONS
function nc_out = write_nc_dimension(obj, nc_out, obc_nodes)
  % define global attributes
  netcdf.putAtt(nc_out.ncid, netcdf.getConstant('NC_GLOBAL'), ...
    'type', 'FVCOM TIME SERIES ELEVATION FORCING FILE')
  netcdf.putAtt(nc_out.ncid, netcdf.getConstant('NC_GLOBAL'), ...
    'title', obj.casename)
  netcdf.putAtt(nc_out.ncid, netcdf.getConstant('NC_GLOBAL'), ...
    'history', 'FILE CREATED using write_FVCOM_elevtide')

  % define dimensions
  nc_out.dim_nboc = netcdf.defDim(nc_out.ncid, 'nobc', obc_nodes); % open boundary node number
  nc_out.dim_time = netcdf.defDim(nc_out.ncid, 'time', netcdf.getConstant('NC_UNLIMITED'));
  % nc_out.dim_date_str = netcdf.defDim(nc_out.ncid, 'DateStrLen', 26);

  % define variables and attributes
  nc_out.var_obc = netcdf.defVar(nc_out.ncid, 'obc_nodes', 'NC_INT', nc_out.dim_nboc);
  netcdf.putAtt(nc_out.ncid, nc_out.var_obc, 'long_name', 'Open Boundary Node Number');
  netcdf.putAtt(nc_out.ncid, nc_out.var_obc, 'grid', 'obc_grid');

  nc_out.var_iint = netcdf.defVar(nc_out.ncid, 'iint', 'NC_INT', nc_out.dim_time);
  netcdf.putAtt(nc_out.ncid, nc_out.var_iint, 'long_name', 'internal mode iteration number');

  nc_out.var_time = netcdf.defVar(nc_out.ncid, 'time', 'NC_FLOAT', nc_out.dim_time);
  netcdf.putAtt(nc_out.ncid, nc_out.var_time, 'long_name', 'time');
  netcdf.putAtt(nc_out.ncid, nc_out.var_time, 'units', 'days since 0.0');
  netcdf.putAtt(nc_out.ncid, nc_out.var_time, 'time_zone', 'none');
  % netcdf.putAtt(nc_out.ncid, time_varid, 'units', 'days since 1858-11-17 00:00:00');
  % netcdf.putAtt(nc_out.ncid, time_varid, 'format', 'modified julian day (MJD)');
  % netcdf.putAtt(nc_out.ncid, time_varid, 'time_zone', 'UTC');

  nc_out.var_itime = netcdf.defVar(nc_out.ncid, 'Itime', 'NC_INT', nc_out.dim_time);
  netcdf.putAtt(nc_out.ncid, nc_out.var_itime, 'units', 'days since 0.0');
  netcdf.putAtt(nc_out.ncid, nc_out.var_itime, 'time_zone', 'none');
  % netcdf.putAtt(nc_out.ncid, itime_varid, 'units', 'days since 1858-11-17 00:00:00');
  % netcdf.putAtt(nc_out.ncid, itime_varid, 'format', 'modified julian day (MJD)');
  % netcdf.putAtt(nc_out.ncid, itime_varid, 'time_zone', 'UTC');

  nc_out.var_itime2 = netcdf.defVar(nc_out.ncid, 'Itime2', 'NC_INT', nc_out.dim_time);
  netcdf.putAtt(nc_out.ncid, nc_out.var_itime2, 'units', 'days since 0.0');
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
function write_nc_file(nc_out, obc_list, time_in_days, elevation)
  Ntime = numel(time_in_days);
  netcdf.putVar(nc_out.ncid, nc_out.var_obc, obc_list);
  netcdf.putVar(nc_out.ncid, nc_out.var_iint, 0, Ntime, 1:Ntime);
  netcdf.putVar(nc_out.ncid, nc_out.var_time, 0, Ntime, time_in_days);
  netcdf.putVar(nc_out.ncid, nc_out.var_itime, floor(time_in_days));
  netcdf.putVar(nc_out.ncid, nc_out.var_itime2, 0, Ntime, mod(time_in_days, 1) * 24 * 3600 * 1000);
  netcdf.putVar(nc_out.ncid, nc_out.var_elevation, elevation);
end % function
