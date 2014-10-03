function newdata = fillgaps (data, minlen)
% FILLGAPS   Fill in gaps and make sure points are consecutive.
%
%   NEWDATA = FILLGAPS (DATA, MINLEN) looks at the points contained
%   in the (presumed) vector DATA, and fills in any gaps which
%   are shorter than MINLEN points (in other words, makes sets
%   of consecutive points).  

% By: Ian Kremenic
% Last modified: 7.21.2000

if (nargin < 2)
	minlen = 100;		% how many missing points might be a glitch
end

newdata = [];

% find non-consecutive portions of data (which are less than minlen)
gaps = diff (data);
gapIndex = find (gaps > 1 & gaps <= minlen);
gapLen = gaps (gapIndex);	% how long is each glitch
gapIndex = [0; gapIndex];
index = 1
start = 1;
% fill in glitches, starting at the end so we don't have to worry
% about bookkeeping to keep track of indices
for theGap = 2:length (gapIndex)
   dataIndex = gapIndex(theGap);
   % filler points
   insertPoints = data (dataIndex) + 1: ...
      data (dataIndex) + gapLen(theGap-1) - 1;
   % points before glitch
   startPoints = data (gapIndex(theGap-1)+1:gapIndex(theGap));
   % fill in
   newdata = [newdata; startPoints; insertPoints'];
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