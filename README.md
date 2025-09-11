# Mat4FVCOM

## Introduction

Mat4FVCOM project access and manipulate FVCOM model data in MATLAB. The project provides classes to access models such as FVCOM, ADCIRC, OTPS, as well as the date and file formats such as the Modified Julian Time and NetCDF.

## Feature

 - Provid Matlab data structure to access FVCOM module data
 - Generate FVCOM input files and visualizing results
 - Reading ADCIRC module files and convert to FVCOM data structure
 - Writing and reading OTPS inputs and predictions for FVCOM open boundary
 - Class to access FVCOM results and date type

## Install

Run the setup.m script to add path in Matlab

```matlab
>> setup
```

## Usage 

### Generate FVCOM input

The following code provide the examples for readign the `*.14` file and generating the MatFVCOM object.

```matlab
>> adcirc = MatAdcirc('h_resolution_0_60_105_150.14');  % read ADCIRC mesh file
>> fvcom = MatFVCOM('hr', 'adcirc', adcirc);            % convert to FVCOM data structure
>> fvcom.write_to_file                                  % write input files for FVCOM module
```

### Add sponge layer and write to file

To add the spong layer and generate the `*.spg` file, use folling code to add the spong layer information.

```matlab
>> fvcom.add_spong_to_open_boundary(1);  % add spong layer to the 1st open boundary, default coefficient is 0.001
>> fvcom.write_to_file
```

### Generate tidal forcing file

To generate the tidal forcing input file, create the MatOTPS objects and convert the OTPS prediction results to netcdf file.

```matlab
>> fvcom.set_time([mjulian_time('2024-01-01'), mjulian_time(2024-01-31)]);  % set the start and end date
>> otps = fvcom.convert_OTPS(1);                                            % convert to MatOTPS object, time interval 1 hour
>> otps.write_file('lat_lon', 'time');  % create OTPS input files, 'lat_lon' and 'time'
>> !predict_tide -ttime < setup.inp     % call OTPS to generate the prediction file 'z.out'
>> fvcom.convert_OTPS_to_netcdf(otps, 'z.out');  % convert 'z.out' to the *.nc file 
```

## Acknowledgements

 - [FVCOM](https://github.com/FVCOM-GitHub/FVCOM.git)
 - [fvcom-toolbox](https://github.com/pwcazenave/fvcom-toolbox.git)
 - [OTPS](https://www.tpxo.net/otps)

