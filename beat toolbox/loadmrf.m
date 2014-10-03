function [xData, yData, zData, Fs, numMarkers, numFrames, fullName] = loadmrf (dataArch, fullName)
% LOADMRF   Load MacReflex data file from disk
%   [XDATA, YDATA, ZDATA, FS, MARKERS, FRAMES, FULLNAME] = LOADMRF 
%   returns the data from the file in three matrices, one each for 
%   x-, y-, and z-dimensions.  
%
%   FS is the sampling frequency at which the data were collected.
%
%   Each matrix has MARKERS columns and FRAMES rows (i.e., one row for
%   each data frame).  The full path- and filename are returned in FULLNAME.
%
%   LOADMRF (DATA_ARCH) performs the same function, but allows the user
%   to specify the architecture of the machine on which the data were 
%   collected (i.e., big- or little-endian).  If not specified, defaults
%   to big-endian (Mac).
%
%   LOADMRF (DATA_ARCH, FILENAME) loads data from the file FILENAME (note: it is
%   assumed that the path is contained in the filename).

% By: Ian Kremenic
% Last modified: 9.28.2000

MAX_MARKERS = 20;			% max number of markers in MacReflex file
MARKER_NAME_SIZE = 16;			% how long can a marker name be
DROPOUT = 10000;		% any coordinate larger than this is a dropout



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let's load some data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if user didn't provide a filename, we need to get one
%if (nargin = 0)
if (~exist ('fullName'))
	[filename, pathname] = uigetfile ('*.*', 'Pick a data file to load...');
	if (filename == 0)
		break;
	end
	fullName = [pathname filename];
end

% if user didn't define data architecture, default to Mac
if (~exist ('dataArch'))
    dataArch = 'b';
end

% open file

macReflexFile = fopen (fullName, 'r', dataArch);

% some offsets for a MacReflex data file (version TDF2)
% (of course, the file header may be found at offset 0)
offsetTrialHeader = 512;
offsetCastInfo = 583;
offsetCalibrationInfo = 1075;
sizeCalibrationHeader = 25;
sizeCalibrationData = 106;

% let's go straight to the cast information and get some marker names
fseek (macReflexFile, offsetCastInfo, 'bof');

% read block ID
blockID = fread (macReflexFile, 1, 'short')

% read marker names
markerNames = fread (macReflexFile, [MARKER_NAME_SIZE, MAX_MARKERS], 'char');
markerNames = (setstr (markerNames'));

markerNames (1:10, :)

% figure out how many cameras from the calibration header
fseek (macReflexFile, offsetCalibrationInfo, 'bof');

calTime = fread (macReflexFile, 1, 'long');
numCameras = fread (macReflexFile, 1, 'short');

% skip the calibration data
calDataBytes = numCameras * sizeCalibrationData;

% go to start of frame data header
offsetFrameHeader = offsetCalibrationInfo + sizeCalibrationHeader + calDataBytes
fseek (macReflexFile, offsetFrameHeader, 'bof');

% get the sampling rate, which is 4 bytes from the start
fseek (macReflexFile, 4, 'cof');
Fs = fread (macReflexFile, 1, 'short')

% now get the number of frames, cameras, and markers
fseek (macReflexFile, 8, 'cof');				% numFrames is 8 bytes from sampling rate
numFrames = fread (macReflexFile, 1, 'long')
temp = fread (macReflexFile, 3, 'short');		% next we have 3 consecutive shorts,
												% the last two of which, we want
numCameras = temp (2)
numMarkers = temp (3)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
offsetFrameData = offsetFrameHeader + 48;		% frame header is 48 bytes
fseek (macReflexFile, offsetFrameData, 'bof');

% how big is a frame and its components?
sizeStatus = 2;		% two byte status
size2D = 8;			% 2-D data is 8 bytes
size3D = 14;		% 3-D data is 14 bytes
size2DData = (sizeStatus + (size2D * numMarkers)) * numCameras;
size3DData = sizeStatus + (size3D * numMarkers);
sizeDataFrame = size2DData + size3DData + 4;		% 4 mysterious bytes!

% 'pre-allocate' space for data, so loading goes faster
xData = zeros (numFrames, numMarkers);
yData = zeros (numFrames, numMarkers);
zData = zeros (numFrames, numMarkers);

% let's grab a frame; forget the 2-D stuff, we'll just take 3-D

tic

theBar = waitbar (0, 'Loading MacReflex data...');

for theFrame = 1:numFrames
	
	% skip the 2-D data in this frame, and 2 bytes of status for 3-D data
	fseek (macReflexFile, size2DData + 2, 'cof');
	
	for theMarker = 1:numMarkers
	
		% read 3-D data and status for each marker
		xyz = fread (macReflexFile, 3, 'float32');
		status = fread (macReflexFile, 1, 'short');
		
		% set any not-a-number's to 0
		notNumIndices = find (isnan (xyz));
		xyz (notNumIndices) = zeros (size (notNumIndices));
%		for i = 1:3
%			if (isnan (xyz (i)))
% | (abs (xyz (i)) < 1e-5) | (abs (xyz (i)) > 1e5))
%				xyz (i) = 0;
%			end
%		end

		xData (theFrame, theMarker) = xyz (1);
		yData (theFrame, theMarker) = xyz (2);
		zData (theFrame, theMarker) = xyz (3);
		
	end
	
	% skip the 4 mysterious bytes at the end of the frame
	fseek (macReflexFile, 4, 'cof');
	waitbar (theFrame / numFrames);
end
close (theBar)

toc

% not quite done yet: if an ENTIRE row is 0, that means that marker doesn't really
% exist, so we can get rid of it
theMarker = 1;
while (theMarker <= numMarkers)
	if (length (find (xData (:, theMarker) == 0)) > (numFrames - (numFrames / 20)))
		xData (:, theMarker) = [];
		yData (:, theMarker) = [];
		zData (:, theMarker) = [];
		numMarkers = numMarkers - 1;
		theMarker = theMarker - 1
	end
    theMarker = theMarker + 1;
end

% fix dropouts
xDrops = getdrops (xData, DROPOUT);
yDrops = getdrops (yData, DROPOUT);
zDrops = getdrops (zData, DROPOUT);
drops = union (xDrops, yDrops);
drops = union (drops, zDrops);
xData = fixdrops (xData, drops, 'spline');
yData = fixdrops (yData, drops, 'spline');
zData = fixdrops (zData, drops, 'spline');

% close file
fclose (macReflexFile);

disp ('Done loading MacReflex data.')

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