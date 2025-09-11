%% Generate FVCOM input
adcirc = MatAdcirc('h_resolution_0_60_105_150.14');  % read ADCIRC mesh file
fvcom = MatFVCOM('hr', 'adcirc', adcirc);            % convert to FVCOM data structure
fvcom.write_to_file                                  % write input files for FVCOM module

%% Add sponge layer and write to file
fvcom.add_spong_to_open_boundary(1);  % add spong layer to the 1st open boundary, default coefficient is 0.001
fvcom.write_to_file

%% Generate tidal forcing file
fvcom.set_time([mjulian_time('2024-01-01'), mjulian_time(2024-01-31)]);  % set the start and end date
otps = fvcom.convert_OTPS(1);                                            % convert to MatOTPS object, time interval 1 hour
otps.write_file('lat_lon', 'time');  % create OTPS input files, 'lat_lon' and 'time'
% !predict_tide -ttime < setup.inp     % call OTPS to generate the prediction file 'z.out'
fvcom.convert_OTPS_to_netcdf(otps, 'z.out');  % convert 'z.out' to the *.nc file 
