function [theMax, maxStart, maxEnd] = maxregion (data, varargin)
% MAXREGION 

% Find region with peak average value
% [peakForce, peakForceRegion]
%                  = peaktime (data, duration, startPt, endPt)
% Finds the region in DATA with the max value for DURATION points, over
% the region defined by STARTPT and ENDPT.  The value and the region over 
% which it occurs are returned in PEAK and PEAKREGION.

% By: Ian Kremenic
% Last modified: 7.16.2001

% if data just a vector, makre sure it is sized properly; we want either a column
% vector or a matrix
if (size (data,1) == 1)
    data = data';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% input args %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% second arg is length of areas at which we are looking; default to 1000
if (nargin < 2)
    duration = 1000;
else
    duration = varargin {1};
end

% third arg is point at which to start looking; default to first point in data
if (nargin < 3)
    startPt = 1;
else
    startPt = varargin {2};
end

% fourth arg is point at which to stop looking; default to last point in data
if (nargin < 4)
    [endPt, numcols] = size (data);
else
    endPt = varargin {3};
end

% if duration is larger than length of data, set duration to one less than length of
% data and reset start and end points appropriately; warn user of this necessity
if (size (data,1) <= duration)
    duration = size (data,1) - 1;
    startPt = 1;
    endPt = size (data,1);
    warning ('Duration for finding max region is larger than your data; resetting duration to length of data');
end

%%%%%%%%% find region of DURATION length where DATA is maximal %%%%%%%%%%
dataRegion = [];
% make sure we don't run past the end of our data
if (endPt + duration > length (data))
   endPt = length (data) - duration;
end

for index = startPt:endPt
   dataRegion = [dataRegion; mean(data (index:index + duration - 1, :))];
end
[theMax, maxStart] = max (abs (dataRegion));
maxStart = maxStart + startPt - 1;
maxEnd = maxStart + duration - 1;

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