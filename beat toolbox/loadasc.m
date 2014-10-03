function [data, Fs, chanLabels, chanUnits, numChans, numSamples, fullName] = loadasc (varargin)
% LOADASC   Import data from an ASCII flat file.

% By: Ian Kremenic
% Last modified: 7.10.2001

if (nargin > 0)
    fullName = varargin {1};
else
    fullName = [];
end
if (nargin > 1)
    dataType = varargin {2};
else
    dataType = 'analog';
end

% if not given a file name, we need to get one
if (isempty (fullName))
    % get file name
	[filename, pathname] = uigetfile ('*.*', 'Pick an ASCII data file to load...');
	if (filename == 0)
		break;
	end
	fullName = [pathname filename];
end

% got the filename; load the data
data = load (fullName, '-ascii');

% are data stored as rows or columns in file
rowsOrCols = questdlg ('Are channels/markers stored as rows or columns in the data file?', ...
    'About the data...', ...
    'Rows', 'Columns', 'Rows');
if (strncmp (rowsOrCols, 'Rows', length(rowsOrCols)))
    data = data';       % transpose for correct order
end

% determine sampling rate
FsStr = inputdlg ('Sample rate:', 'Sampling rate for data...', 1, {num2str(1000)});
Fs = str2num (FsStr{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remaining stuff is different depending on what kind of data
switch dataType
case 'analog'
    % number of channels, samples, etc...
    [numSamples, numChans] = size (data);
    chanUnits = 'Volts';
    chanLabels = [];
    for i = 1:numChans
        chanLabels = strvcat (chanLabels, ['Channel ' num2str(i)]);
    end

case 'motion'
    % user will have to provide number of markers/dimensions; use this loop to ensure
    % data are not more than 3-dimensional (we're not Einstein here)
    numDims = 4;
    while (numDims > 3)
        answer = inputdlg ({'No. of markers:', 'No. of dimensions (1-D, 2-D, 3-D):', 'First col/row is frame no. (y/n):'}, ...
            'Info on motion data:', 1, ...
            {num2str(floor(numChans/3)) num2str(3) 'n'});
        numMarkers = str2num (answer {1});
        numDims = str2num (answer {2});
        firstIsFrameNum = answer {3};
        % check to be sure no. markers/dims matches data
        numCols = numMarkers * numDims;
        if (strncmp (firstIsFrameNum, 'y', length(firstIsFrameNum)))
            numCols = numCols - 1;
            data (:, 1) = [];
        end
        % if they don't match, do it again
        if (numCols ~= numChans)
            numDims = 4;
        end
        errordlg ('There is something screwy with the data you entered', 'Error');
    end
    % got the necessary info; deal out the data as required
    X = [];
    Y = [];
    Z = [];
    whichMarker = 1;
    for index = 1:numDims:numCols
        X (:, whichMarker) = data (:, index);
        if (numDims > 1)
            Y (:, whichMarker) = data (:, index+1);
        end
        if (numDims > 2)
            Z (:, whichMarker) = data (:, index+2);
        end
        whichMarker = whichMarker + 1;
    end
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
