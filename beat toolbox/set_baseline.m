function out = set_baseline (in, baseRegion, baseLevel)
% SET_BASELINE  Set the baseline level of a signal
%   OUT = SET_BASELINE (IN, BASEREGION, BASELEVEL) sets the baseline of the
%   signal IN to BASELEVEL.  The region where the baseline of the signal
%   lives is defined by BASEREGION.  BASELEVEL, if not specified, defaults
%   to 0.  BASEREGION defaults to the first 50 points (i.e., 1:50).
%   Works on vectors for now.

% baseline level set to 0 if not specified
if (nargin < 3)
   baseLevel = 0;
end
% baseline region first 50 points if not specified
if (nargin < 2)
   baseRegion = 1:50;
end

% what are we adding to everything
baseAdjustment = baseLevel - mean (in (baseRegion));

% do that adjustment thang!
out = in + baseAdjustment;

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