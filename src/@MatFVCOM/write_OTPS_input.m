%WRITE_OTPS_INPUT Generate input files for OTPS (Oregon Tidal Prediction Software).
% 
%   WRITE_OTPS_INPUT(OBJ, DT_HOUR) creates the necessary input files for
%   OTPS based on the object's properties and the specified time interval.
%
%   Inputs:
%       OBJ     - An instance of the MatFVCOM class containing the data
%                 and properties required for generating OTPS input files.
%       DT_HOUR - Time interval in hours for the OTPS input data.
%
%   This function is part of the Mat4FVCOM toolbox and is used to prepare
%   data for tidal prediction using the OTPS software.
function write_OTPS_input(obj, dt_hour)
  write_time_file(obj.time.start, obj.time.end, dt_hour)
  wirte_lat_lon(obj)
end % function

% WRITE_LAT_LON Writes latitude and longitude data to an OTPS input file.
%
% This method is part of the MatFVCOM class and is used to write the
% latitude and longitude information of the object to a file formatted
% for use with the OTPS (Oregon State University Tidal Prediction Software).
%
% Syntax:
%   obj.write_lat_lon()
%
% Inputs:
%   None (uses the properties of the MatFVCOM object).
%
% Outputs:
%   None (writes data to a file).
%
% Example:
%   obj = MatFVCOM(...); % Initialize the MatFVCOM object
%   obj.write_lat_lon(); % Write latitude and longitude to OTPS input file
%
% Note:
%   Ensure that the object contains valid latitude and longitude data
%   before calling this method.
function wirte_lat_lon(obj)
  file_h = fopen('ops_latlon.dat', 'w');

  for k = 1:numel(obj.open_boundary)
    for i = 1:numel(obj.open_boundary(k).vertex)
      index = obj.open_boundary(k).vertex(i);
      fprintf(file_h, '%f %f\n', obj.lat(index), obj.lon(index));
    end
  end

  fclose(file_h);
end % function

%WRITE_TIME_FILE Generate a time file for OTPS input.
% 
%   This function creates a time file for OTPS (Oregon State Tidal Prediction
%   Software) input based on the specified start time, finish time, and time
%   step in hours.
%
%   INPUTS:
%       start_t   - Start time as a datetime object.
%       finish_t  - Finish time as a datetime object.
%       dt_hour   - Time step in hours (numeric).
%
%   OUTPUTS:
%       This function does not return any outputs but writes the generated
%       time data to a file.
%
%   USAGE:
%       write_time_file(start_t, finish_t, dt_hour)
%
%   EXAMPLE:
%       start_t = datetime(2023, 1, 1, 0, 0, 0);
%       finish_t = datetime(2023, 1, 2, 0, 0, 0);
%       dt_hour = 1;
%       write_time_file(start_t, finish_t, dt_hour);
%
%   NOTE:
%       Ensure that the input times are provided as datetime objects and that
%       dt_hour is a positive numeric value.
function write_time_file(start_t, finish_t, dt_hour)
  time_vec = start_t.julian_day:dt_hour / 24:finish_t.julian_day;

  file_h = fopen('ops_time.dat', 'w');

  for i = 1:length(time_vec)
    time = mjulian_time(time_vec(i));
    fprintf(file_h, '%4d %02d %02d %02d %02d %02.0f\n', ...
      time.year, time.month, time.day, time.hour, time.minu, time.sec);
  end

  fclose(file_h);
end % function
