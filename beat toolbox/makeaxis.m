function xAxis = makeAxis (sampInt, numPoints, axisType)
% MAKEAXIS  Make 'correct' x-axis for plotting time or frequency data.
%   XAXIS = MAKEAXIS (SAMPINT, NUMPOINTS, AXIS_TYPE)
%   This function will take a sampling interval and generate a true
%   horizontal axis for use in plotting data.  SAMPINT is the 
%   sampling interval between data points being plotted.  NUMPOINTS is the
%   number of data points that are being plotted.  AXIS_TYPE
%   is a (character) flag.  If set to 'f' it creates a frequency axis
%   (to be used when plotting Fourier transforms).  If set to 't', it will
%   make a time axis to plot the time-domain signal (this is the default).
%   It returns a COLUMN vector.

% By: Ian Kremenic

if (axisType == 'f')
	% generate freq axis
	sampFreq = 1 / sampInt;
	xAxis = linspace (0, sampFreq * ((numPoints - 1) / numPoints), numPoints);
else
	% generate time axis
	xAxis = linspace (0, sampInt * (numPoints - 1), numPoints);
end

% make it a column vector rather than a row vector
xAxis = xAxis';

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
