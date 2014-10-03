function out = rms_emg (data, numPoints)
% RMS_EMG   Rectify and RMS an EMG signal.
%       OUT = RMS_EMG (DATA, NUMPOINTS) computes uses the data contained in DATA
%       and computes its RMS by squaring each data point, averaging NUMPOINTS / 2 
%       points before and after the point to get a new value for the point, and then 
%       taking the square root.  If DATA is a matrix, each column is assumed to be
%       a channel of EMG.
%       NUMPOINTS + 1 are used if NUMPOINTS is even.  IF NUMPOINTS is not entered, it
%       defaults to 51.

% By: Ian Kremenic

if (nargin == 1)
    numPoints = 51;
end

% first, rectify data
data = data .^ 2;

% setup kernel to convolve with; it should average the points
if (mod (numPoints, 2) == 0)    % it's easier if there are an odd number of points
    numPoints = numPoints + 1;
end
convKernel = ones (1, numPoints) / numPoints;
% how much extra is put at beginning and end of sequence
padding = (numPoints - 1) / 2;

% is the input data a vector or matrix
[numrows numcols] = size (data);
if (numrows == 1 | numcols == 1)
    % it's a vector, just convolve
    out = conv (data, convKernel);
    % get rid of excess at beginning and end
    out (1:padding) = [];
    out (end - padding + 1:end) = [];
else
    % it's a matrix, convolve each column
    out = zeros (numrows + numPoints - 1, numcols);     % pre-allocate
    for i = 1:numcols
        out (:, i) = conv (data (:, i), convKernel);
    end
    % get rid of excess at beginning and end
    out (1:padding, :) = [];
    out (end - padding + 1:end, :) = [];
end

out = sqrt (out);
size (out)

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