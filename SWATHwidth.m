function allwidths = SWATHwidth(DV_SWATH,minradius)
%% inputs a Swathobj and gets valley width at each swath centerpoint
% SWATHobj created following stream network using the Valley class grid where in valley is 1 and outvalley is 0
%
%
%
% Syntax
%
%     allwidths=SWATHwidth(DV_SWATH,100);
%
% Description
%
%     SWATHwidth creates a 3xn array holding x y and width info. from a
%     stream network to swath object swath object SWATHobj from the valley
%     class gridobj
%       Right now the minimum value searches through all streams at once
%       rather than one stream at a time. 
% 
% Input arguments
%
%     DV_SWATH:     SWATHobj created from STREAMOBJ2SWATHOBJ with valley
%                  class GRIDobj
%     minradius: number (in meters) distance for the searching radius 
%               to get minumum value
%
% Output arguments
%
%     allwidths:    nx4 array nx1 is X position, nx2 is y position, nx3
%     is the width value, and nx4 is the width value, smoothed by the
%     minimum value of an allwidths nx3 point within minradius.
%
% Example
%
%     pre-reqs need to make a swath object from a stream object
%           this example uses streamobj S, and GRidobj DV, with points
%           every 10 m along the streams, and crossprofiles 500 m wide
%
%       DV_SWATH=STREAMobj2SWATHobj(S,DV,'dx',10,'width',500);
%
% See also: SWATHobj
%





% Author: paul morgan
% Date: pass 1, dec 2022
%  jan 23 22, try to fix single stream swath error I think it worked
%
%  Jan  24, 2023: Added in the minradius for both single and multiple
%  streams, it takes another for loop so I hope it doesn;t take too long. 
%
%






%rename the swath profile 
% should be from the valley bottom layer, 1 = in valley and 0 = out valley
SWATH=DV_SWATH;
%SWATH=SW_DV;
% make a structure to hold all of the valley width locations
num_streams=length(SWATH)
totalprofs=length(SWATH);

%% if the number of streams is only 1 then we need to modify the script to avoid bracket indexing
if num_streams == 1
%% copy of the below but without bracket indexing

%do a little loop to get the first allwidths value...
% the below set of calculations are all for the 1,1 width location, 
Z_outvalley_1=SWATH.Z <1;
Z_disty_1=SWATH.disty;
Z_out_dist_1=Z_disty_1(Z_outvalley_1(:,1));%
Z_out_pos_1=Z_out_dist_1(Z_out_dist_1>0);
Z_out_neg_1=Z_out_dist_1(Z_out_dist_1<0);
valleywidth_1=min(Z_out_pos_1)+min(abs(Z_out_neg_1));
midpointXY_1=SWATH.xy(1,:); % the xy position of the midpoint
allwidths=[midpointXY_1 valleywidth_1 0]; %added in the zero to hold the nearby minimum

disp('only one stream')
 sss=1
    X = sprintf(' stream %d of %d',sss,length(SWATH));
    disp(X)
    %sss=1; %the loop variable for the stream segments
    
    Z_outvalley=SWATH.Z <1; %define the swath profile z points that are out of the valley 1= not in valley
    Z_disty=SWATH.disty;   %define the distance along the profile array for this set of profiles
    
    
    % loop 1.1 through the profiles within one stream
    for pp=1:length(SWATH.xy) % each profile pp
        %pp=1; %the variable for the profile segments
        % using logical array, zout dist only holds distance values for points outside of the valley
        %then we break it into positive and negative values to get the
        %lowest of each, and add those together to get the valley width
        Z_out_dist=Z_disty(Z_outvalley(:,pp));
        Z_out_pos=Z_out_dist(Z_out_dist>0);% all the positive values
        %this is a problem if it never leaves the river valey
        Z_out_neg=Z_out_dist(Z_out_dist<0);
        valleywidthpp=min(Z_out_pos)+min(abs(Z_out_neg));
        % if one direction never leaves the river valley, so Z_out has no
        % values, so valleywidth is empty then skip this loop. 
        if isempty(valleywidthpp)
            continue
        end %end if
    
        %get the middle point of the profile
        midpointXY=SWATH.xy(pp,:); % the xy position of the midpoint
        allwidths=[allwidths;midpointXY valleywidthpp 0]; % still keep zero asplaceholder for min
    end %end loop through each profile
    

%get the moving average values for this stream
        %link to helpful post about this
%https://www.mathworks.com/matlabcentral/answers/344961-points-too-close-xy-space?s_tid=prof_contriblnk


disp("end onestream") %just for troubleshooting breakpoint



%%%%%%%%%%%%%%%%%%%%%%%  Get the minumum nearby value %%%%%%%%
Xdistances = pdist2(allwidths(:,1),allwidths(:,1));
Ydistances = pdist2(allwidths(:,2),allwidths(:,2));
totdistances=sqrt(Xdistances.^2+Ydistances.^2); %pythagorean 
% make a total length by total lenght matrix where the x value is the
%rowiswidth=repmat(allwidths(:,3),1,length(allwidths)); % makes an array the same size of the distance array where the rows are all the same
% and corespond to the width of that point from the row index
inradius = totdistances < minradius; % creates logical on the 670x670 where in radius is 1
% I give up and will loop through the points
for ppp = 1:length(allwidths); %for each profile point ppp in the stream
    pppinradius=inradius(:,ppp); % logical of nearby points to this ppp point
    pppmininradius=min(allwidths(pppinradius,3)); % grab the minimum value of the nearby values
    allwidths(ppp,4)=pppmininradius;           % add it to the allwidths
end %end loop through each point




else %numstreams if statememt
%% for multistreams




% loop 1 through the streams


%do a little loop to get the first allwidths value...
% the below set of calculations are all for the 1,1 width location, 
Z_outvalley_1=SWATH{1}.Z <1;
Z_disty_1=SWATH{1}.disty;
Z_out_dist_1=Z_disty_1(Z_outvalley_1(:,1));%
Z_out_pos_1=Z_out_dist_1(Z_out_dist_1>0);
Z_out_neg_1=Z_out_dist_1(Z_out_dist_1<0);
valleywidth_1=min(Z_out_pos_1)+min(abs(Z_out_neg_1));
midpointXY_1=SWATH{1}.xy(1,:); % the xy position of the midpoint
allwidths=[midpointXY_1 valleywidth_1 0]; %addded placeholder for min

disp('starting the streams loop')
for sss=1:length(SWATH)
    X = sprintf(' stream %d of %d',sss,length(SWATH));
    disp(X)
    %sss=1; %the loop variable for the stream segments
    
    Z_outvalley=SWATH{sss}.Z <1; %define the swath profile z points that are out of the valley 1= not in valley
    Z_disty=SWATH{sss}.disty;   %define the distance along the profile array for this set of profiles
    
    
    % loop 1.1 through the profiles within one stream
    %so that minimum calc can be done stream by stream
    for pp=1:length(SWATH{sss}.xy) % each profile pp
        %pp=1; %the variable for the profile segments
        % using logical array, zout dist only holds distance values for points outside of the valley
        %then we break it into positive and negative values to get the
        %lowest of each, and add those together to get the valley width
        Z_out_dist=Z_disty(Z_outvalley(:,pp));
        Z_out_pos=Z_out_dist(Z_out_dist>0);% all the positive values
        %this is a problem if it never leaves the river valey
        Z_out_neg=Z_out_dist(Z_out_dist<0);
        valleywidthpp=min(Z_out_pos)+min(abs(Z_out_neg));
        % if one direction never leaves the river valley, so Z_out has no
        % values, so valleywidth is empty then skip this loop. 
        if isempty(valleywidthpp)
            continue
        end %end if
    
        %get the middle point of the profile
        midpointXY=SWATH{sss}.xy(pp,:); % the xy position of the midpoint
        allwidths=[allwidths;midpointXY valleywidthpp 0]; %keep in min placeholder
    end %end loop through each profile
end % end loop through each stream
    
    


%get the moving average values for this stream
        %link to helpful post about this
%https://www.mathworks.com/matlabcentral/answers/344961-points-too-close-xy-space?s_tid=prof_contriblnk

%%%%%%%%%%%%%%%%%%%%%%%  Get the minumum nearby value %%%%%%%%
Xdistances = pdist2(allwidths(:,1),allwidths(:,1));
Ydistances = pdist2(allwidths(:,2),allwidths(:,2));
totdistances=sqrt(Xdistances.^2+Ydistances.^2); %pythagorean 
% make a total length by total lenght matrix where the x value is the
%rowiswidth=repmat(allwidths(:,3),1,length(allwidths)); % makes an array the same size of the distance array where the rows are all the same
% and corespond to the width of that point from the row index
inradius = totdistances < minradius; % creates logical on the 670x670 where in radius is 1
% I give up and will loop through the points
for ppp = 1:length(allwidths); %for each profile point ppp in the stream
    pppinradius=inradius(:,ppp); % logical of nearby points to this ppp point
    pppmininradius=min(allwidths(pppinradius,3)); % grab the minimum value of the nearby values
    allwidths(ppp,4)=pppmininradius;           % add it to the allwidths
end %end loop through each point





end %end numstreams if statement







end %end function