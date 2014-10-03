function fm = medfreq (spectrum, freq)
% MEDFREQ  Compute median frequency of a signal.
%   FM = MEDFREQ (SPECTRUM, FREQ) computes the median frequency 
%   of a signal with spectrum given by SPECTRUM, computed at
%   the frequencies given by FREQ, returning the median 
%   frequency in FM.
%   It uses the CUMSUM function to compute the area under
%   the spectrum curve.

% Last modified:7.13.99
% by: Ian Kremenic

% Determine the "area" under the psd curve at each point
area = cumsum (spectrum);

% Find the halfway point
areaMax = area (length (area));
areaTarget = .5 * areaMax;
areaHalf = 0;
index = 0;
while (areaHalf < areaTarget)
	index = index + 1;
	areaHalf = area (index);
end

% Return the median frequency
fm = freq (index);

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