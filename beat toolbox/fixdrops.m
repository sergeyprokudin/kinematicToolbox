function fixed = fixdrops (data, dropouts, method)
% FIXDROPS   Fix dropouts in data.
%   FIXED = FIXDROPS (DATA, DROPOUTS, METHOD) fixes dropouts in DATA
%   indicated by DROPOUTS by eliminating said points (GETDROPS would be
%   a good way to determine these points).
%   The points are then interpolated using the method specified by METHOD.
%   METHOD is a string which can be:
%   - 'spline': use cubic spline interpolation
%   - 'linear': linear interpolation between last and next good points
%   If METHOD is omitted, it defaults to 'spline'.
%   If DATA is a matrix, each column is treated as a series of data.

% By: Ian Kremenic
% Last modified: 7.21.2000

% make sure we know how to interpolate data points
if (nargin < 3)
   method = 'spline';
end

% make sure the interpolation method is supported/spelled correctly
if (~strcmp (method, 'linear') & ~strcmp (method, 'spline'))
   errMsg = sprintf ('FIXDROPS ERROR: Invalid interpolation method ''%s'' specified', method);
   disp (errMsg);
   return;
end

% figure out size of data
[numrows numcols] = size (data);
% if row vector, transpose to make computing consistent
rowvect = 0;
if (numrows == 1)
   data = data';
   numrows = numcols;
   numcols = 1;
   rowvect = 1;
end

% find dropouts, interpolate
fixed = zeros (numrows, numcols);	% allocate space
for theGuy = 1:numcols
   tmpx = (1:numrows)';			% original x-axis
   tmpy = data (:, theGuy);	% original y-data
   % DROPOUTS describes all data as one big vector; adjust it appropriately to each column
   dropIndex = find (dropouts <= theGuy * numrows);
   drops = dropouts (dropIndex) - (theGuy - 1) * numrows;
   dropouts (dropIndex) = [];		% if we don't get rid of these, we'll see them again
   tmpx (drops) = [];		% toss points that are dropouts
   tmpy (drops) = [];		% toss points that are dropouts
   fixed (:, theGuy) = interp1 (tmpx, tmpy, (1:numrows)', method);
end

% if original data were row vector, transpose to get row vector back
if (rowvect)
   fixed = fixed';
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