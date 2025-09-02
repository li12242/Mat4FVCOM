% get modified julian time array
% Input:
%   start_time - start time, .e.g '2014-01-01 00:00:00'
%   end_time - end time, .e.g '2014-04-01 00:00:00'
%   dt_day - time dt_day, days, .e.g  dt_day = 1/24
% Output:
%   time - real time dates, size [ntime,1]
% Usages:
%   time = get_julian_time(startStr, endStr, dt_day)
function time = get_julian_time(time_string_start, time_string_end, dt_day)

  timevec = datevec(time_string_start);
  start_time = FVCOM.Time.greg2mjulian ...
    (timevec(1), timevec(2), timevec(3), timevec(4), timevec(5), timevec(6));

  timevec = datevec(time_string_end);
  end_time = FVCOM.Time.greg2mjulian ...
    (timevec(1), timevec(2), timevec(3), timevec(4), timevec(5), timevec(6));

  % time = start_time:dt_day:end_time+dt_day;
  ntime = ceil((end_time - start_time) ./ dt_day);
  time = linspace(start_time, end_time, ntime);
end
