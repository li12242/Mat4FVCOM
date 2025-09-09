% DESCRIPTION:
%    Generate FVCOM 3.x format input files based on a ADCIRC grad file and
%    spicific open obundary elevation
%
% OUTPUT:
%    FVCOM input files: (casename='test')
%     ./
%     ├── test_cor.dat
%     ├── test_dep.dat
%     ├── test_grd.dat
%     ├── test_obc.dat
%     ├── test_obc.nc
%     ├── test_river.nc
%     ├── test_sigma.dat
%     ├── test_spg.dat
%     └── test_tsobc.nc
%
% EXAMPLE USAGE
%
% Author(s):  
%    li12242 (Tianjin University)
%   
%==============================================================================
global ftbverbose
ftbverbose = true;
%================================================%
casename = 'test'; 
filepath = '/Users/mac/Documents/Model/FVCOM/FVCOM3.2.1/Examples/IdealEstuary2';
inDir = [filepath, '/map/map/'];
outDir = [filepath, '/inp'];

%% mesh
import FVCOM.Mesh.*

Mobj = read_ADCIRC_cartesian_mesh([inDir, 'IdealEstuary.grd']);

import FVCOM.PreProcess.*
% write cor.dat file
write_FVCOM_bath(Mobj,casename)
% write grd.dat file
write_FVCOM_grid(Mobj,casename)
% write obc.dat file
write_FVCOM_obc(Mobj,casename) 
% write dep.dat file
write_FVCOM_depth(Mobj,casename)

%% show map
FVCOM.PostProcess.draw_map(Mobj)
hold on;
plot(Mobj.x(Mobj.obc_nodes{1}), Mobj.y(Mobj.obc_nodes{1}), 'ro') % plot boundary

%% open boundary
startTimeStr = '2014-01-01 00:00:00'; endTimeStr = '2014-01-03 10:00:00';
interval = 1./2./24; % days
timeSer = FVCOM.Time.get_julian_time(startTimeStr, endTimeStr, interval);

Mobj.surfaceElevation = set_elevtide(Mobj, timeSer, @functional_elev);
MJD = timeSer;

% write obc.nc file
write_FVCOM_elevtide(Mobj,MJD,casename,casename)


%% sponge file
% write sponge propertity into Mobj
SpongeCoeff = 0.001;
% assume the boundary node number is [1:Mobj.nObcNodes]
[spongeRadius] = calc_sponge_radius(Mobj,1:Mobj.nObcNodes);
SpongeName = 'spong1';
[Mobj]  = add_sponge_nodes_list(Mobj,1:Mobj.nObcNodes,SpongeName,spongeRadius,SpongeCoeff);
% write spg.dat file
write_FVCOM_sponge(Mobj,casename)

%% sigma layer
Mobj.nSiglay = 10; Mobj.sigType = 'Uniform';
write_FVCOM_sigma(casename, Mobj.sigType, Mobj.nSiglay+1)

%% ts obc file
in_temp = 26; in_salt = 33;
write_FVCOM_tsobc(casename,MJD,Mobj.nSiglay,in_temp,in_salt,Mobj)

%% river file
nTimes = numel(timeSer);
totalFlux = ones(1, nTimes); totalFlux(:) = 625; % m3/s
node_id = 1893:1897; % river nodes
temp = 26*ones(nTimes,1);
salt = 10*ones(nTimes,1);
RiverFile = [casename,'_river.nc'];
nRivnodes = numel(node_id);
RiverInfo1 = 'idealized estuary river';
RiverInfo2 = 'event profile';
RiverName = 'tstRiver';
write_FVCOM_river(RiverFile,RiverName,nRivnodes,MJD,totalFlux,temp,salt,...
    RiverInfo1,RiverInfo2)
River_vertical_distribution = zeros(1, Mobj.nSiglay);
River_vertical_distribution(:) = 1./Mobj.nSiglay;
RiverNameList = 'tstRiver_namelist.nml';
write_FVCOM_riverNameList(RiverNameList, RiverFile, RiverName, node_id,...
    River_vertical_distribution)

%% move file
movefile([pwd,'/',casename,'_cor.dat'],outDir);
movefile([pwd,'/',casename,'_grd.dat'],outDir);
movefile([pwd,'/',casename,'_obc.dat'],outDir);
movefile([pwd,'/',casename,'_spg.dat'],outDir);
movefile([pwd,'/',casename,'_dep.dat'],outDir);
movefile([pwd,'/',casename,'_obc.nc'],outDir);
movefile([pwd,'/',casename,'_sigma.dat'],outDir);
movefile([pwd,'/',casename,'_tsobc.nc'],outDir);
movefile([pwd,'/',casename,'_river.nc'],outDir);
movefile([pwd,'/',RiverNameList],outDir);

%================================================%
% estimate the out mode time
%================================================%
zeta = max(max(abs(Mobj.surfaceElevation))); u =0.1;
[Mobj] = estimate_ts(Mobj,u,zeta);
%================================================%
