classdef mjulian_time < handle
  % MJULIAN_TIME Class for handling modified Julian time.
  %
  % This class provides methods and properties to work with modified Julian
  % time, which is commonly used in scientific and engineering applications
  % for representing time in a continuous numerical format.
  %
  properties
    julian_day % modified julian time

    year % year date
    month % month
    day % day
    hour % hour
    minu % minute
    sec % second
    dayweek % day of the week
    dategreg % [year, month, day, hour, minu, sec]

    mtime % matlab time
  end % properties

  methods

    function obj = mjulian_time(varargin)
      % MJULIAN_TIME Constructor for the mjulian_time class.
      % This function initializes an instance of the mjulian_time class.
      % Usage:
      % 
      %   mt = mjulian_time('YYYY-MM-DD HH:MM:SS');
      %   mt = mjulian_time(matlab_datenum);
      %   mt = mjulian_time(year, month, day, hour, minu, sec);
      % 

      obj.mtime = datenum(varargin{:});
      obj.dategreg = datevec(obj.mtime);
      [obj.year, obj.month, obj.day, obj.hour, obj.minu, obj.sec] = datevec(obj.mtime);
      [obj.julian_day, obj.dayweek] = greg2mjulian( ...
        obj.dategreg(1), obj.dategreg(2), obj.dategreg(3), ...
        obj.dategreg(4), obj.dategreg(5), obj.dategreg(6) ...
      );
    end % function

  end % methods

end % classdef

%
% Convert the Gregorian dates to Modified Julian dates.
% Usage:
%     mjulianday = greg2mjulian(yyyy,mm,dd,HH,MM,SS)
function [mjulianday, dayweek] = greg2mjulian(year, month, day, hour, mint, sec)
  [mjulianday, dayweek] = greg2julian(year, month, day, hour, mint, sec);
  mjulianday = mjulianday - 2400000.5;
end % function

% This function converts the Gregorian dates to Julian dates.
%
% 0. Syntax:
% [JD,julianday] = juliandate(year,month,day,hour,min,sec)
%
% 1. Inputs:
%     year, month, day = date in Gregorian calendar.
%     hour,min,sec = time at universal time.
%
% 2. Outputs:
%     JD = Julian date.
%     julianday = day of week.
%
% 3. Example:
%  >> [a,b] = greg2julian(2006,5,30,2,30,28)
%  a =
%
%           2453885.60449074
%  b =
%
%  Tuesday
%
%  4. Notes:
%     - For all common era (CE) dates in the Gregorian calendar, and for more
%     information, check the referents.
%     - The function was tested, using  the julian date converter of U.S. Naval Observatory and
%     the results were similar. You can check it.
%     - Trying to do the life... more easy with the conversions.
%
% 5. Referents:
%     Astronomical Applications Department. "Julian Date Converter". From U.S. Naval Observatory.
%               http://aa.usno.navy.mil/data/docs/JulianDate.html
%     Duffett-Smith, P. (1992).  Practical Astronomy with Your Calculator.
%               Cambridge University Press, England:  pp. 9.
%     Seidelmann, P. K. (1992). Explanatory Supplement to the Astronomical Almanac.
%               University Science Books, USA.  pp. 55-56.
%      Weisstein, Eric W.  "Julian Date".  From World of Astronomy--A Wolfram Web Resource.
%               http://scienceworld.wolfram.com/astronomy/JulianDate.html
%
% Gabriel Ruiz Mtz.
% May-2006
%
% Modifications:
% 04/06/06: To find the days, it was only changed the loop to a cell array. Thanks to J??e.
% ------------------------------------------------------------------------------------------------------------
function [JD, julianday] = greg2julian(year, month, day, hour, min, sec)

  narginchk(6, 6)
  timeut = hour + (min / 60) + (sec / 3600);

  %For common era (CE), anno domini (AD)
  JD = (367 * year) - floor (7 * (year + floor((month + 9) / 12)) / 4) - ...
    floor(3 * (floor((year + (month - 9) / 7) / 100) + 1) / 4) + ...
    floor((275 * month) / 9) + day + 1721028.5 + (timeut / 24);
  a = (JD + 1.5) / 7;
  frac = a - floor(a);
  n = floor(frac * 7);
  julianday = {'Sunday' 'Monday' 'Tuesday' 'Wednesday' 'Thursday' 'Friday' 'Saturday'};
  julianday = julianday{n + 1};

end % function

% Convert a modified Julian day to a Matlab datestr style string
%
% DESCRIPTION
%   Convert a modified Julian day to a Matlab datestr style string
%
% INPUT
%    MJD    = modified Julian day
%    Format = [optical] date format, .e.g 'yyyy-mm-dd HH:MM:SS'
%
% OUTPUT
%    strout = Matlab datestr style string
%               .e.g '2000-03-01 15:45:17'
%
% EXAMPLE USAGE
%    S = MJUL2STR(time, 'yyyy-mm-dd HH:MM:SS')
%
% Author(s)
%    li12242 (Tianjin University)
%
%==========================================================================
function strout = mjul2str(MJD, varargin)

  mjul2matlab = 678942; %difference between modified Julian day 0 and Matlab day 0

  if nargin > 1
    strout = datestr(MJD + mjul2matlab, varargin{1});
  else
    strout = datestr(MJD + mjul2matlab);
  end

end % function

% This function converts Modified Julian dates to Gregorian dates.
function [year, month, day, hour, minu, sec, dayweek, dategreg] = mjulian2greg(MJD)
  [year, month, day, hour, minu, sec, dayweek, dategreg] = julian2greg(MJD + 2400000.5);
end % function

% This function converts the Julian dates to Gregorian dates.
%
% 0. Syntax:
% [day,month,year,hour,min,sec,dayweek] = julian2greg(JD)
%
% 1. Inputs:
%     JD = Julian date.
%
% 2. Outputs:
%     year, month, day, dayweek = date in Gregorian calendar.
%     hour, min, sec = time at universal time.
%
% 3. Example:
%  >> [a,b,c,d,e,f,g,h] = julian2greg(2453887.60481)
%  a =
%     2006
%  b =
%     6
%  c =
%     1
%  d =
%     2
%  e =
%     30
%  f =
%     56
%  g =
%     Thursday
%  h =
%       1     6     2006     2     30     56
%
% 4. Notes:
%     - For all common era (CE) dates in the Gregorian calendar.
%     - The function was tested, using  the julian date converter of U.S. Naval Observatory and
%     the results were similar. You can check it.
%     - Trying to do the life... more easy with the conversions.
%
% 5. Referents:
%     Astronomical Applications Department. "Julian Date Converter". From U.S. Naval Observatory.
%               http://aa.usno.navy.mil/data/docs/JulianDate.html
%     Duffett-Smith, P. (1992).  Practical Astronomy with Your Calculator.
%               Cambridge University Press, England:  pp. 8,9.
%
% Gabriel Ruiz Mtz.
% Jun-2006
% ____________________________________________________________________________________________
function [year, month, day, hour, minu, sec, dayweek, dategreg] = julian2greg(JD)

  narginchk(1, 1)

  I = floor(JD + 0.5);
  Fr = abs(I - (JD + 0.5));

  if I >= 2299160
    A = floor((I - 1867216.25) / 36524.25);
    a4 = floor(A / 4);
    B = I + 1 + A - a4;
  else
    B = I;
  end

  C = B + 1524;
  D = floor((C - 122.1) / 365.25);
  E = floor(365.25 * D);
  G = floor((C - E) / 30.6001);
  day = floor(C - E + Fr - floor(30.6001 * G));

  if G <= 13.5
    month = G - 1;
  else
    month = G - 13;
  end

  if month > 2.5
    year = D - 4716;
  else
    year = D - 4715;
  end

  hour = floor(Fr * 24);
  minu = floor(abs(hour - (Fr * 24)) * 60);
  minufrac = (abs(hour - (Fr * 24)) * 60);
  sec = ceil(abs(minu - minufrac) * 60);
  AA = (JD + 1.5) / 7;
  nd = floor((abs(floor(AA) - AA)) * 7);
  dayweek = {'Sunday' 'Monday' 'Tuesday' 'Wednesday' 'Thursday' 'Friday' 'Saturday'};
  dayweek = dayweek{nd + 1};
  format('long', 'g');
  dategreg = [day month year hour minu sec];

end % function
