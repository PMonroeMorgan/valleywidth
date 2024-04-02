function allwidths = DEM2widths(DEM,streamarea,elevthreshold,swath_dx,minradius)
%% function to run all the steps in matlab to go from a DEM to the 
% 
%
%
% Syntax
%
%     allwidths =
%     DEM2widths(DEM,streamarea,elevthreshold,swath_dx,minradius);
%
%   or with values
% allwidths = DEM2widths(DEM,2250000,10,10,200);
%
%
% Description
%
%      
% 
% Input arguments
%
%     DEM:     GRIDobj, better be in utm coordinates and m for elevation
%     streamarea: number drainage area threshold for stream creation, in pixels,
%                 so depends on dem resolution coded for 1m resolution
%     elevthreshold: number height above river where valley ends for valley
%                    width calculation
%     swath_dx: number, how closely spaced in m points along stream
%                     profiles are
%    minradius: number, in meters the radius of the moving window around the
%                       points to grab the minimum valley width 
%
% Output arguments
%
%     allwidths:    nx4 array nx1 is X position, nx2 is y position, nx3
%     is the width value, and nx4 is the width value, smoothed by the
%     minimum value of an allwidths nx3 point within minradius.
%
% Example
%        prereqs: DEM=GRIDobj('path/to/demfile.tif')
%        DEM=GRIDobj('D:\Paul\DEM\OregonLidar\WBD_basins\Basin170900030211\R_utm_m_170900030211.tif')
%        allwidths = DEM2widths(DEM,2250000,10,10,200)
%
% Author: paul morgan
% Date: first created, 1/23/2023


%% prep dem for streams
  DEMf = fillsinks(DEM);
  %% stream objects
disp('calculating streams')
% calculate flow accumulation
FD = FLOWobj(DEMf);
A  = flowacc(FD);
% Note that flowacc returns the number of cells draining
% in a cell. 
W = A>streamarea; %Number from struble paper for low end of slide dam observations
%W = A>2250000; %Number from struble paper for low end of slide dam observations
% create an instance of STREAMobj
S = STREAMobj(FD,W);


%% function for valley classification
plotnum=0
DV = valleyclass_elev(DEM,S,FD,elevthreshold,plotnum)

%% swath width extraction
SW_DV=STREAMobj2SWATHobj(S,DV,'dx',swath_dx);
%minradius=200;
allwidths=SWATHwidth(SW_DV,minradius);



end % end function
