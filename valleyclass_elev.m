function DV = valleyclass_elev(DEM,S,FD,elevthreshold,plotnum)
%% valleyclass function for DEM, Stream network, and thresholds
%   A function to use a stream network, the DEM elevation, and  a threshold
%   elevation to create a gridobj of valley class, where 1 is in a valley
%   and 0 is out.
%
% Syntax
%
%     DV = valleyclass_elev(DEM,S,FD,elevthreshold,plotnum)
%
% Description
%
%   valleyclass_elev creates a Valley class grid (DV) where in valley is 1 and out valley is 0
%   uses the topotoolbox function vertdistance to stream to get elevation
%   above stream and the elevthreshold set to pick valley pixels that are
%   within an elevation from the stream. Note that vertdistance to stream
%   is computed along flow paths, not the nearest euclidean distance
% 
% Input arguments
%
%     DEM     class GRIDobj elevation file, this code fills sinks
%     S       class STREAMobj created from the DEM input
%     FD      class FLOWobj  created from the DEM input
%     elevthreshold: number set number for the cutoff of valley and
%               outvalley pixels, should be in meters
%     plotnum:  number if 1 makes plots if 0 no plots
%
% Output arguments
%
%     DV    a GRIDobj of the same dimentions as DEM where 1 is in a
%     valley and 2 is out of a valley
%
% Example
%
%     
% Author: paul morgan
% Date: first iteration 1/20/23

%input DEM, streams, Thresholds
% DEM=DEM
% elevthreshold=10;   %elevation threshold for elevation
% S=S;
% FD=FD;


%% getting in all the variables, that should be inputs later
disp("Setting up the DEM")
% but right now, def not a function
%DEMo = GRIDobj('/Users/pmorgan/UW/DATA/DEM/OR/testsquare2_m_rp.tif');
%DEM=DEMo;
DEMf = fillsinks(DEM);
%GD = gradient8(DEMf,'degree');


%elevthreshold=10;   %elevation threshold for elevation
%slopethreshold=20;  % slope in degrees above slope of local channel

 %% stream objects
% no longer created in this function, but the below is an example of stream
% object and flow object creation

% disp('calculating streams')
% % calculate flow accumulation
% FD = FLOWobj(DEMf);
% A  = flowacc(FD);
% % Note that flowacc returns the number of cells draining
% % in a cell. Here we choose a minimum drainage area of 10000 cells.
% %W = A>100000;
% %W = A>1000000; %for testing a big lidar dem
% W = A>2250000; %Number from struble paper for low end of slide dam observations
% % create an instance of STREAMobj
% S = STREAMobj(FD,W);

%% step one, get the elevation above the streams, using the function
disp('finding DZ')
DZ = vertdistance2stream(FD,S,DEMf);

%% try to do the above with slope
% so Dslope is the grid object representing the slope value above the slope
% of the nearest stream most of this code modified from vertdistance2stream

% oops this doesn't work 

% disp('finding Dslope')
% Dslope = GD;
% Dslope.Z = -inf(GD.size);
% Dslope.Z(S.IXgrid) = GD.Z(S.IXgrid);
% 
% ix = FD.ix;
% ixc = FD.ixc;
% for r = numel(ix):-1:1
%     Dslope.Z(ix(r)) = max(Dslope.Z(ix(r)),Dslope.Z(ixc(r)));
% end
% 
% Dslope = GD-Dslope;


%% trying to use the syntax of vertdistance2stream to get the valleyclass
DV = DEM; %DV is the valleyclass gridobject
DV.Z = zeros(DEM.size); % start by reseting it to zeros

DV.Z(S.IXgrid) = 2; % set each stream cell equal t




%% try to do the if statement

ix = FD.ix; % (givers)  not sure what this is
ixc = FD.ixc; %(recievers) again not sure what this is, some type of edge attribute 
%ix and ixc are slightly less than the number of open cells

for r = numel(ix):-1:1; %loop through every point?
    if DZ.Z(ix(r)) < elevthreshold;
      DV.Z(ix(r))=1; 
    end
end





% the below if statement was for when I thought that Dslope worked, but now
% it doesn't
% for r = numel(ix):-1:1; %loop through every point?
%     if Dslope.Z(ix(r)) < slopethreshold && DZ.Z(ix(r)) < elevthreshold;
%       DV.Z(ix(r))=1; 
%     end
% end

%DZ = DEM-DZ;

%% postprocess the valeyclass gridobj
%DV=fillsinks(DV);



%% troubleshooting plots

if plotnum == 1
    disp("plotting")

    figure(2)
    imageschs(DEMf,[],'colormap',[1 1 1],'colorbar',false)
    hold on
    imagesc(DV, 'AlphaData', .3)
    plot(S,'k','linestyle','-','linewidth',3)
    hold off
    
    % just the dem
    figure(3)
    imagesc(DEMf,[0 300])
    colorbar
    hold on
    plot(S,'k','linestyle','-','linewidth',3)
    hold off
    
    
    
%     %plot the slope
%     figure(4)
%     imagesc(GD,[0 45])
%     colorbar
%     hold on
%     plot(S,'k','linestyle','--','linewidth',2)
%     hold off
    
    
    % % plot Dslope
    % figure(5)
    % imagesc(Dslope,[-45 45])
    % colormap hsv
    % colorbar
    % hold on
    % plot(S,'k','linestyle','-','linewidth',3)
    % hold off
    
    %plot DZ
    figure(6)
    imagesc(DZ,[-100 100])
    colormap hsv
    colorbar
    hold on
    plot(S,'k','linestyle','-','linewidth',3)
    hold off
else 
    disp("not plotting")
%imageschs(DEMf,G,'ticklabel','nice','colorbarylabel','Slope [-]','caxis',[0 1])
end %end plotnum if statement

end % end function



