function events = threshold_cross (data, thresholdLevel, onTime, offTime, upOrDown)

% By: Ian Kremenic
% Last modified: 10.31.2001

events = [];

switch upOrDown
case 'up'
    % crossing threshold, going up
    events = find (data > thresholdLevel);
    % if not long enough, get rid of events
    
    
    %%%%%%%%%%%%%%%%%% temp!!!!!! what does this code do? %%%%%%%%%%%%%%%%%%%%%%%%%%%
%    theEvent = 1;
%    while (theEvent <= length (events))
%        tmp = find (events > events(theEvent) & events <= events(theEvent) + onTime);
%        if (~isempty (tmp))
%            % get rid of guys that are too close
%            tmpLen = length (tmp);
%            events (theEvent+1:theEvent+tmpLen) = [];
%        end
%        theEvent = theEvent + 1;
%    end
    % fill in little glitches in remaining events
    events = fillgaps (events, offTime);
case 'down'
    % crossing threshold, going down
    events = find (data < thresholdLevel);
otherwise
    % crossing threshold in either direction
    events1 = find (data < thresholdLevel);
    events2 = find (Data > thresholdLevel);
end





    tmpPts = find (peakPtsLeft > peakPtsLeft(thePt) & peakPtsLeft <= peakPtsLeft(thePt) + minDuration);
    if (~isempty (tmpPts))
        % get rid of the guys that are too close
        tmpLen = length (tmpPts);
        peakPtsLeft (thePt+1:thePt+tmpLen) = [];
    end
    thePt = thePt + 1;
end











% these should be args
numMinPts = 500;			% how many points to examine for 'min' value
numMinVelPts = 500;		% how many points to examine for 'max' rate of change

% footswitch or force data?
if (strcmp (dataType, 'switch') | strcmp (dataType, 'force'))
   % find minimum and all points 'near' it
   sortData = sort (data);
   minData = sortData (1:numMinPts);
   
   % mean and std of these points
   minDataMean = mean (minData);
   minDataStd = std (minData);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %          add code to look at whether increasing/decreasing
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % look at derivative to find where signal is changing rapidly
   dataVel = diff (data);
   b = fir1 (10, .1);			% smooth it a bit
   dataVel = filtfilt (b, 1, dataVel);
   % find min and nearby points
   sortDataVel = sort (abs (dataVel));
   minDataVel = sortDataVel (1:numMinVelPts);
   % mean and std of these points
   minDataVelMean = mean (minDataVel);
   minDataVelStd = std (minDataVel);
   
%    % find minimum and all points 'near' it
%    minData = min (abs (data)) + eps;
%    downPoints = find (data < 1.5 * minData);
%    
%    % compute mean and standard dev. for these points
%    minDataMean = mean (data (downPoints))
%    minDataStd = std (data (downPoints))
    
	% find points less than XXX std's from mean with appropriately
	% slow rate of change
   upPoints = find (data < (minDataMean + (numstds * minDataStd)));
   % figure out where signal changes slowly 
   slowPoints = find (dataVel > (minDataVelMean + (numstds * minDataVelStd)));
   % real points we want is the intersection of the sets of slow points
   % and where we've determined signal
   upPoints = intersect (upPoints, slowPoints);
   
   % points should be consecutive except for little glitches; make
   % sure they are
   % NOTE: The 100 should be an argument to this function
   upPoints = fillgaps (upPoints, 100);
   
   % we now have clusters of consecutive points around the minima of the
   % signal, in areas where it is relatively flat
    % go through these points; if current index plus one is equal to the
    % next index, then not a heel strike (i.e., the next sample satisfied
    % the conditions for heel strike, therefore this point is not a heel strike)
    for index = 1:length (upPoints)-1
        if (upPoints (index + 1) ~= upPoints (index) + 1)
            events = [events upPoints(index)];
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% motion data
elseif (strcmp (dataType, 'motion'))
	% first, let's compute the velocity, and find the indices where 
	% it's negative
   vel = diff (data);
   b = fir1 (10, .3);
   vel = filtfilt (b, 1, vel);
   if (strcmp (side, 'l'))
      neg_vel = find (vel < 0);
   else
      neg_vel = find (vel > 0);		% no this doesn't make sense, unless you read the comments above
   end
   
	% go through the indices; if the current index less one is equal to the
	% previous index, then it's not a heel strike (i.e., the previous sample
	% was also < 0, therefore, not a 0 crossing)
	for index = 2:length (neg_vel)
		if (neg_vel (index - 1) ~= (neg_vel (index) - 1))
			events = [events neg_vel(index)];
		end
	end

% typo...
else
	disp ('HEELSTRIKE ERROR: Invalid data type entered...');
	return;
end

% Part of the BEAT Toolbox.
% Copyright (C) 2001 Nicholas Institute of Sports Medicine and Athletic Trauma
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.