function motps = convert_OTPS_prediction(obj, varargin)
  % CONVERT_OTPS_PREDICTION Convert MatFVCOM object to OTPS object for tidal 
  % prediction of open boundary.
  %
  % This method is part of the MatFVCOM class and is used to convert the
  % object's data into a format suitable for OTPS (Oregon State University
  % Tidal Prediction Software) input files. It generates latitude, longitude,
  % and time files based on the object's properties.
  %
  % Usage:
  %
  % .. code-block:: matlab
  %
  %   motps = obj.convert_OTPS(1/24); % for 1-hour per step
  %   motps = obj.convert_OTPS(time_vec); % for time array
  %   motps = obj.convert_OTPS(start_time, end_time, 1/24); % for time range

  obc_index = [obj.open_boundary(:).vertex];
  obc_index = unique(obc_index);

  if nargin == 2
    % check if the time is set
    if isempty(obj.time)
      error('FVCOM time is not set. Please set the time using obj.set_time(start_t, end_t) method.');
    end

    if isnumeric(varargin{1}) & isscalar(varargin{1})
      dt_hour = varargin{1};
      mtime_vec = obj.time.start.mtime:dt_hour / 24:obj.time.end.mtime;
      motps = MatOTPS(obj.lon(obc_index), obj.lat(obc_index), mtime_vec);
    elseif isnumeric(varargin{1}) & isvector(varargin{1})
      mtime_vec = varargin{1};
      motps = MatOTPS(obj.lon(obc_index), obj.lat(obc_index), mtime_vec);
    else
      error('When providing one argument, it must be a numeric scalar or vector representing time.');
    end % if
  elseif nargin == 4
    start_t = varargin{1};
    end_t = varargin{2};
    dt_hour = varargin{3};
    mtime_vec = datenum(start_t):dt_hour / 24:datenum(end_t);
    motps = MatOTPS(obj.lon(obc_index), obj.lat(obc_index), mtime_vec);
  else
    error('Invalid number of input arguments.');
  end % if

end % function
