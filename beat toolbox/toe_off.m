function events = toe_off (data, dataType, numstds, side)
%TOE_OFF  Pick toe off events from data.
%
%   TOE_OFF finds the toe off events in a set of gait data.
%
%   TOE_OFF (DATA, DATATYPE, NUMSTDS, SIDE) finds the toe off events in the
%   data given by DATA, which is of type DATATYPE.  DATATYPE is a
%   string which is either 'motion', 'force', or 'switch'.  When DATATYPE is
%   'motion', DATA is assumed to be a vector containing the
%   forward-backward motion of the toe.  When DATATYPE is 'switch',
%   DATA is assumed to be a vector of footswitch data for the heel (similarly,
%   for 'force', force plate data is used, which is processed the same way as
%   'switch').  If DATATYPE is not given, it is assumed to be 'motion'.  NUMSTDS
%   refers not to sexually transmitted diseases, but to the number of standard
%   deviations used in determining whether a point is a toe off if the
%   data is specified as either 'switch' or 'force'; it defaults to 5.  SIDE
%   is specified as 'l' or 'r', and tells whether this is data for the right
%   or left side for V-Scope data (or for any other data where the coordinate
%   system flips from one side to the other.  It defaults to 'l' (which should
%   be appropraite for data taken with other systems).
%
%   For 'motion' data, toe off is assumed to occur when the 
%   velocity of the toe changes from backward to forward (passes
%   through 0, going up) (this is reversed if side is specified as 'r').

% By: Ian Kremenic
% Last modified: 7.19.2000

if (nargin == 1)
	dataType = 'motion';
    side = 'l';
    numstds = 5;
elseif (nargin == 2)
    side = 'l';
    numstds = 5;
elseif (nargin == 3)
    side = 'l';
end
events = [];

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
   
   
   
   
%    % find minimum and all points 'near' it
%    minData = min (abs (data)) + eps
%    downPoints = find (data < 1.5 * minData);
%    
%    % compute mean and standard dev. for these points
%    minDataMean = mean (data (downPoints))
%    minDataStd = std (data (downPoints))
    
   % find points less than XXX std's from mean
   upPoints = find (data < (minDataMean + (numstds * minDataStd)));
    
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
   % figure out where signal changes slowly 
   slowPoints = find (dataVel < (minDataVelMean + (numstds * minDataVelStd)));
   
   % real points we want is the intersection of the sets of slow points
   % and where we've determined signal
   upPoints = intersect (slowPoints, upPoints);
%   upPoints = intersect (slowPoints, fastPoints);

   % points should be consecutive except for little glitches; make
   % sure they are
   % NOTE: The 100 should be an argument to this function
   upPoints = fillgaps (upPoints, 100);
   
   % we now have clusters of consecutive points around the minima of the
   % signal, in areas where it is relatively flat
    % go through these points; if one less than current index is equal to the 
    % prior index, then not a toe off (i.e., the previous sample satisfies
    % the conditions for toe off, therefore this point is not a toe off)
    for index = 2:length (upPoints)
        if (upPoints (index - 1) ~= upPoints (index) - 1)
            events = [events upPoints(index)];
        end
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% motion data?
elseif (strcmp (dataType, 'motion'))
	% first, let's compute the velocity, and find the indices where 
	% it's positive
   vel = diff (data);
   b = fir1 (10, .3);
   vel = filtfilt (b, 1, vel);
   if (strcmp (side, 'l'))
      pos_vel = find (vel > 0);
   else
      pos_vel = find (vel < 0);		% no this doesn't make sense, unless you read the comments above
   end
   
	% go through the indices; if the current index less one is equal to the
	% previous index, then it's not a toe off (i.e., the previous sample
	% was also > 0, therefore, not a 0 crossing)
	for index = 2:length (pos_vel)
		if (pos_vel (index - 1) ~= (pos_vel (index) - 1))
			events = [events pos_vel(index)];
		end
	end

% typo...
else
	disp ('TOE_OFF ERROR: Invalid data type entered...');
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
