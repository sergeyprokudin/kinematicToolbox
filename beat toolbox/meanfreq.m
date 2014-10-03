function fm = meanfreq (spectrum, freq)
% MEANFREQ  Compute mean frequency of a signal.
%   FM = MEANFREQ (SPECTRUM, FREQ) computes the mean power frequency 
%   of a signal with spectrum given by SPECTRUM, computed at
%   the frequencies given by FREQ, returning the mean power 
%   frequency in FM.
%   FM is a weighted sum of the spectrum (sum of SPECTRUM * FREQ)
%   divided by a sum of SPECTRUM.

% Last modified:7.13.99
% by: Ian Kremenic

% compute weighted sum and sum of spectrum
wtSum = sum (spectrum .* freq);
plainSum = sum (spectrum);

% Return the median frequency
fm = wtSum / plainSum;

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