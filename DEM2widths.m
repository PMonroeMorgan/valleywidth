function [allwidths, DV]= DEM2widths(DEM,streamarea,elevthreshold,swath_dx,minradius,swath_width)
%% function to run all the steps in matlab to go from a DEM to the 
% 
%
%
% Syntax
%
%     [allwidths,DV] =
%     DEM2widths(DEM,streamarea,elevthreshold,swath_dx,minradius);
%
%   or with values
% [allwidths,DV] = DEM2widths(DEM,2250000,10,10,200);
%
%
% Description
%
%      
% 
% Input arguments
%
%     DEM:     GRIDobj, better be in utm coordinates and m for elevation
% 
%     streamarea: number drainage area threshold for stream creation, in pixels,
%                 so depends on dem resolution coded for 1m resolution
%     elevthreshold: number height above river where valley ends for valley
%                    width calculation
%     swath_dx: number, how closely spaced in m points along stream
%                     profiles are
%    minradius: number, in meters the radius of the moving window around the
%                       points to grab the minimum valley width 
%     Not anymore --writeDV: string, if it is writeDV then script will write DV raster to
%                       file, if it's anything else it wont
%       swath_width: number, in meters with along cross profiles to measure
% Output arguments
%
%     allwidths:    nx6 array nx1 is X position, nx2 is y position, nx3
%     is the width value, and nx4 is the width value, smoothed by the
%     minimum value of an allwidths nx3 point within minradius,nx4 is the
%     drainage area in m, nx5 is the stream gradient in deg smoothed by crs
%     function.
%
% Example
%        prereqs: DEM=GRIDobj('path/to/demfile.tif')
%        DEM=GRIDobj('D:\Paul\DEM\OregonLidar\WBD_basins\Basin170900030211\R_utm_m_170900030211.tif')
%        allwidths = DEM2widths(DEM,2250000,10,10,200,'nowriteDV')
%
% Author: paul morgan
% Date: 1/23/2023 first created
%       1/26/2023 added in writeDV, and added DV to output, which is
%       probably more useful
%       1/30/23 add in removeshortstreams to get the swathobj to work
%       9/14/23 add in drainage area and slope extraction
%       2/20/24 add in swath_width input argument to increase max valley width calculation
%       3/6/24 switched from fill to fill then carve flow object workflows

%% prep dem for streams
  %DEMf = fillsinks(DEM);
  %% stream objects
disp('calculating streams')
% calculate flow accumulation
%FD = FLOWobj(DEMf,'preprocess','carve');
FD = FLOWobj(DEM,'preprocess','carve');

A  = flowacc(FD);
% Note that flowacc returns the number of cells draining
% in a cell. 
W = A>streamarea; %Number from struble paper for low end of slide dam observations
%W = A>2250000; %Number from struble paper for low end of slide dam observations
% create an instance of STREAMobj
S = STREAMobj(FD,W);

%remove short streams so that the swaths work
%I chose the minradius to to be the stream length cutoff, not sure how to
%justify that

S=removeshortstreams(S, minradius); 
%S=removeshortstreams(S, minradius/2); 



%% function for valley classification


plotnum=0
DV = valleyclass_elev(DEM,S,FD,elevthreshold,plotnum);
%% writing valley class
% if writeDV == 'writeDV'
%     print('writing the valley class raster to file')
% %write the DV file
%     huc12numstr=erase(DEM.name,'R_utm_m_')
%     DVfilepath=['D:\Paul\DEM\OregonLidar\testexports\Basin' huc12numstr '\R_utm_m_' huc12numstr '_DV_A1e10s20.tif']
%  GRIDobj2geotiff(DV,DVfilepath);
% end %end if writDV
%
%% swath width extraction
disp('swath width extraction')
SW_DV=STREAMobj2SWATHobj(S,DV,'dx',swath_dx,'width',swath_width);
%SW_DV=STREAMobj2SWATHobj_pmmedit(S,DV,'dx',swath_dx);




%minradius=200;
allwidths=SWATHwidth(SW_DV,minradius);



%% extract drainage areas  and 
% get drainage areas at stream locations
disp('extracting drainage area')

%first convert the Area grid into meters
A_m   = A*DEM.cellsize^2; %grid with drainage areas
S_A_m   = getnal(S,A_m);  % Stream with drainage areas extracted

% use dsearchn matlab function to get stream points closest to allwidths
% points
%streamareapoints=[S.x(:),S.y(:),a_m];
I_Sforallwidths=dsearchn([S.x(:),S.y(:)],allwidths(:,1:2)); %index of points in S near the allwidths points
allwidth_DAs=S_A_m(I_Sforallwidths);  % drainage area at those points
allwidths = cat(2, allwidths,allwidth_DAs); %add that DA into the allwidths.

%% do this again with the gradient
disp('extracting gradients')

% get a better gradient value, smooth the stream profile first
SmoZ = crs(S,DEM);  
g2=gradient(S,SmoZ,'unit','degree'); %then use the smoothed zs to get the gradients


%dont need to dsearchn again because already did it with this S
allwidth_g2s=g2(I_Sforallwidths);
allwidths = cat(2, allwidths,allwidth_g2s); %add that g2 into the allwidths.


%I_agradient=dsearchn(areapoints(:,1:2),allwidths(:,1:2));


end % end function
