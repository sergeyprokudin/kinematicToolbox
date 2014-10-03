function [cycles, newOff] = make_cycles (data, on, off, numPoints)
% MAKE_CYCLES   Divide cyclic data into its component cycles, and create average cycle.
%   [CYCLES, NEWOFF] = MAKE_CYCLES (DATA, ON, OFF, NUMPOINTS) 
%   makes cycles out of the data contained in the vector DATA, 
%   with ON and OFF being vectors containing which points to use 
%   for contact on and off.  Cycles are created based on the points
%   indicating contact ON (e.g., heel strike).
%
%   NUMPOINTS is an optional argument for the number of points in 
%   a cycle; it defaults to 250.
%
%   The first column in CYCLES is the average; the remainder are the the
%   individual cycles.  NEWOFF gives the indices in each average cycle of
%   where the points given by OFF occurred.

% By: Ian Kremenic
% Last modified: 7.21.2000

theBar = waitbar (0, 'Making cycles...');

if (nargin < 4)
    numPoints = 250;
end

% first, divide angle data into cycles based on contact (e.g., heel strike)
tmp = cell (1, length (on) - 1);			% pre-allocate cell array
for i = 2:length (on),
  tmp {i - 1} = data (on (i - 1):on (i));
end

% figure out which off points we're interested in; the first one should start after
% the first on point
getRidOf = find (off < on (1));
off (getRidOf) = [];

% of the remaining off points, lets normalize them to the beginning of their cycles
newOff = off - on (1:length (off));

% now, let's blow 'em all out to numPoints points
[numrows numcols] = size (tmp);
cycles = zeros (numPoints, numcols + 1);	% pre-allocate (yes, one extra column for avg.)

for i = 1:numcols
   len (i) = length (tmp {i});
   newIndexStep = (len (i) - 1) / (numPoints - 1);
   newIndex = 1:newIndexStep:len (i);
   cycles (:, i + 1) = interp1 (1:len (i), tmp {i}, newIndex, 'spline')';
   waitbar (i / numcols);
end

close (theBar);

% now that that's done, we need to make the average cycle, i.e., cycles (:, 1)
cycles (:, 1) = mean (cycles (:, 2:numcols + 1), 2);

% compute avg length of a cycle; this'll be used to position the 'average' off point
avgLen = mean (len);

% make average off point
offAvg = mean (newOff);
newOff = round ([offAvg newOff] * (numPoints + 1) / avgLen);
   
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