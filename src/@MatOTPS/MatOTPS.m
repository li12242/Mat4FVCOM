classdef MatOTPS < handle
  % MATOTPS A class for handling OTPS data and operations.
  %   This class provides methods and properties to interact with OTPS data,
  %   enabling users to perform various operations and analyses on OTPS datasets.
  %

  properties
    Nt % number of time steps
    Nv % number of vertices

    mtime_vec % time array

    lon % lontitude array
    lat % latitude array
  end % properties

  methods
    function obj = MatOTPS(varargin)
      % MATOTPS Constructor for the MatOTPS class.
      % This function initializes an instance of the MatOTPS class.
      % Usage:
      %
      %   otps = MatOTPS(lon, lat, mtime_vec);
      %   otps = MatOTPS(lat_lon_file, mtime_vec);
      %   otps = MatOTPS(lat_lon_time_file);
      %
      p = inputParser;
      if nargin == 3
        addRequired(p, 'lon', @(x) isnumeric(x) && isvector(x));
        addRequired(p, 'lat', @(x) isnumeric(x) && isvector(x));
        addRequired(p, 'mtime_vec', @(x) isnumeric(x) && isvector(x));
        parse(p, varargin{:});

        % lon, lat, mtime_vec
        obj.lon = p.Results.lon;
        obj.lat = p.Results.lat;
        obj.mtime_vec = p.Results.mtime_vec;
      elseif nargin == 2
        addRequired(p, 'lat_lon_file', @(x) isstring(x) || ischar(x));
        addRequired(p, 'time_file', @(x) isstring(x) || ischar(x));
        parse(p, varargin{:});

        [obj.lat, obj.lon] = obj.read_lat_lon_file(p.Results.lat_lon_file);
        obj.mtime_vec = obj.read_time_file(p.Results.time_file);
      elseif nargin == 1
        % lat_lon_time_file
        addRequired(p, 'lat_lon_time_file', @(x) isstring(x) || ischar(x));
        parse(p, varargin{:});
        [obj.lat, obj.lon, obj.mtime_vec] = obj.read_lat_lon_time_file(p.Results.lat_lon_time_file);
      else
        error('Invalid number of input arguments.');
      end % if

      obj.Nt = length(obj.mtime_vec);
      obj.Nv = length(obj.lon);
    end % function

    function write_file(obj, varargin)
      % WRITE_FILE Writes data to a file.
      % This function writes latitude, longitude, and time data to a specified
      % file in a formatted manner.
      % Usage:
      %
      %   obj.write_file('lat_lon_time');
      %   obj.write_file('lat_lon', 'time');
      %

      p = inputParser;
      if nargin == 2
        addRequired(p, 'latlon_time_file', @(x) isstring(x) || ischar(x));
        parse(p, varargin{:});
        obj.write_lat_lon_time(obj, p.Results.latlon_time_file);
      elseif nargin == 3
        addRequired(p, 'latlon_file', @(x) isstring(x) || ischar(x));
        addRequired(p, 'time_file', @(x) isstring(x) || ischar(x));
        parse(p, varargin{:});
        obj.write_lat_lon(obj, p.Results.latlon_file);
        obj.write_time(obj, p.Results.time_file);
      else
        error('Invalid number of input arguments.');
      end

    end % function

  end % methods

  methods (Static)
    function [time, z] = read_prediction(obj, filename)
      % READ_PREDICTION Reads time and tidal elevation from the OTPS prediction file.
      % This function reads time and tidal elevation data from a specified
      % OTPS prediction file and read the prediction elevation.
      % Usage:
      %
      %   [time, z] = obj.read_prediction(obj, 'z.out');
      %
      file_h = fopen(filename);
      header_num = 6;
      for i = 1:header_num
        fgetl(file_h);
      end

      Ntime = obj.Nt - 1;
      z = zeros(Ntime, obj.Nv);

      % [data, nsize] = fscanf(file_h, '%f %f', [2, 1]); % read lat, lon
      for i = 1:obj.Nv
        fgetl(file_h); % skip the line: lat lon
        [data, nsize] = fscanf(file_h, '%d.%d.%d %d:%d:%d %f %f\n', [8, inf]);
        % fprintf('reading %d data for vertex %d\n', nsize, i);
        if nsize > 8 * Ntime
          z(:, i) = data(7, 1:end - 1)'; % jump the lat lon
        else 
          z(:, i) = data(7, :)'; % for the last vertex
        end
      end
      fclose(file_h);

      % use the last vertex values
      time = datenum( ...
        data(3, 1:end), data(1, 1:end), data(2, 1:end), ...
        data(4, 1:end), data(5, 1:end), data(6, 1:end) ...
      );
    end % function

    function [lat, lon] = read_lat_lon_file(file)
      % READ_LAT_LON_FILE Reads latitude and longitude from the OTPS input file.
      % This function reads latitude and longitude data from a specified
      % OTPS input file and assigns them to the object's properties.
      % Usage:
      %
      %   [lat, lon] = obj.read_lat_lon_file(file);
      %
      [lat, lon] = textread(file, '%f %f');
    end % function

    function [lat, lon, mtime_vec] = read_lat_lon_time_file(file)
      % READ_LAT_LON_TIME_FILE Reads latitude, longitude, and time from the OTPS input file.
      % This function reads latitude, longitude, and time data from a specified
      % OTPS input file and assigns them to the object's properties.
      % Usage:
      %
      %   [lat, lon, mtime_vec] = obj.read_lat_lon_time_file(file);
      %
      [lat, lon, year, month, day, hour, minu, sec] = textread(file, '%f %f %d %d %d %d %d %d');
      mtime_vec = datenum(year, month, day, hour, minu, sec);
    end % function

    function mtime_vec = read_time_file(file)
      % READ_TIME_FILE Reads time from the OTPS input file.
      % This function reads time data from a specified OTPS input file and
      % assigns it to the object's properties.
      % Usage:
      %
      %   mtime_vec = obj.read_time_file(file);
      %
      [year, month, day, hour, minu, sec] = textread(file, '%d %d %d %d %d %d');
      mtime_vec = datenum(year, month, day, hour, minu, sec);
    end % function

    function write_lat_lon_time(obj, filename)
      % WRITE_LAT_LON_TIME Writes latitude, longitude, and time to a file.
      % This function writes the latitude, longitude, and time data to a specified
      % file in a formatted manner.
      % Usage:
      %
      %   obj.write_lat_lon_time(filename);
      %
      fid = fopen(filename, 'w');
      for t = 1:obj.Nt
        for i = 1:obj.Nv
          [year, month, day, hour, minu, sec] = datevec(obj.mtime_vec(t));
          fprintf(fid, '%10.4f %10.4f %4d %2d %2d %2d %2d %2d\n', ...
            obj.lat(i), obj.lon(i), year, month, day, hour, minu, sec);
        end
      end
      fclose(fid);
    end % function

    function write_lat_lon(obj, filename)
      % WRITE_LAT_LON Writes latitude and longitude to a file.
      % This function writes the latitude and longitude data to a specified
      % file in a formatted manner.
      % Usage:
      %
      %   obj.write_lat_lon(filename);
      %
      fid = fopen(filename, 'w');
      for i = 1:obj.Nv
        fprintf(fid, '%10.4f %10.4f\n', obj.lat(i), obj.lon(i));
      end
      fclose(fid);
    end % function

    function write_time(obj, filename)
      % WRITE_TIME Writes time data to a file.
      % This function writes the time data to a specified file in a formatted manner.
      % Usage:
      %
      %   obj.write_time(filename);
      %
      fid = fopen(filename, 'w');
      for i = 1:obj.Nt
        [year, month, day, hour, minu, sec] = datevec(obj.mtime_vec(i));
        fprintf( ...
          fid, '%4d     %2d     %2d     %2d     %2d     %2d\n', ...
          year, month, day, hour, minu, sec ...
        );
      end
      fclose(fid);
    end % function
  end % methods

end % classdef
