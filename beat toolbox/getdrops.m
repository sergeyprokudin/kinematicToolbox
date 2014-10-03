function dropouts = getdrops (data, threshold)
% GETDROPS   Get dropouts in data.
%   DROPOUTS = GETDROPS (DATA, THRESHOLD) gets dropouts in the data
%   given in data by eliminating any points that are greater then THRESHOLD.

% By: Ian Kremenic
% Last modified: 7.21.2000

% find dropouts
dropouts = find (abs (data) > threshold);

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