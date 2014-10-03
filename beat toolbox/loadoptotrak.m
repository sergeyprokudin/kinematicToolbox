function [xData, yData, zData, Fs, numMarkers, numFrames, fullName] = loadoptotrak (fullName)
% LOADNOR   Load a Noraxon MyoSoft file of analog data in ASCII or binary format
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
% Last modified: 8.16.2002

if (nargin < 1)
	[filename, pathname] = uigetfile ('*.*', 'Pick an Optotrak data file to load...');
	if (filename == 0)
		break;
	end
	fullName = [pathname filename];
end

% open file
optotrakFile = fopen (fullName, 'rt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% suck in header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% stuff about file header
HEADER_START_LABEL = 'Input File';
NUM_MARKERS_LABEL = 'Number of Items';
NUM_DIMS_LABEL = 'Number of Subitems';
NUM_FRAMES_LABEL = 'Number of Frames';
FS_LABEL = 'Frequency';
LABEL_DELIM = ':';
%HEADER_END_LABEL = '::START';
HEADER_END_LABEL = 'Frame';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% does file have a header?
% if so, read it in, parse it, and load data
% if not, start the import wizard thingy, and ask the user some questions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get rid of leading whitespace in the line
theLine = fliplr (deblank (fliplr (fgets (optotrakFile))));
if (~isempty (strmatch (HEADER_START_LABEL, theLine)))

	%while (isempty (findstr (theLine, HEADER_END_LABEL)))
	while (isempty (strmatch (HEADER_END_LABEL, theLine)))
        if (~isempty (findstr (theLine, NUM_MARKERS_LABEL)))
	%        numMarkersPos = length (NUM_MARKERS_LABEL);
            numMarkersPos = findstr (theLine, ':');
            numMarkers = str2num (theLine (numMarkersPos(1)+1:end));
            %numMarkers = str2num (theLine (numMarkersPos:end)) - 1;
        elseif (~isempty (findstr (theLine, NUM_DIMS_LABEL)))
	%        numDimsPos = length (NUM_DIMS_LABEL);
            numDimsPos = findstr (theLine, ':');
            numDims = str2num (theLine (numDimsPos(1)+1:end));
        elseif (~isempty (findstr (theLine, NUM_FRAMES_LABEL)))
	%        numFramesPos = length (NUM_FRAMES_LABEL);
            numFramesPos = findstr (theLine, ':');
            numFrames = str2num (theLine (numFramesPos(1)+1:end));
        % this one's different; other lines could contain this, so use strncmp
        elseif (strncmp (theLine, FS_LABEL, length (FS_LABEL)))
	%        FsPos = length (FS_LABEL);
            FsPos = findstr (theLine, ':');
            Fs = str2num (theLine (FsPos(1)+1:end));
        end
        theLine = fliplr (deblank (fliplr (fgets (optotrakFile))));
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% done with header; suck in data
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% one more line with marker numbers
	%theLine = fgets (optotrakFile);
	
	
	% now we've got datab
	% how many columns in file? no. markers * no. of dims + 1 (frame no.)
	numCols = numMarkers * numDims + 1;
    firstIsFrameNum = 'y';
	% read a line in order to determine whether data are comma-separated
	fPosition = ftell (optotrakFile);
	theLine = fgets (optotrakFile);
	fseek (optotrakFile, fPosition, 'bof');
	if (isempty (findstr (theLine, ',')))
        tmpFormat = ' %f';
	else
        tmpFormat = ', %f';
	end
	theFormat = repmat(tmpFormat, 1, numCols);
	if (findstr (theFormat, ','))
        theFormat (1) = [];
    end
	theFormat = [theFormat '\n'];
	data = fscanf (optotrakFile, theFormat, [numCols inf]);
	data = data';

    fclose (optotrakFile);
    
else
    fclose (optotrakFile);
    tmp = uiimport (fullName);
    % the struct element that our data were placed in has the same name as
    % the file, but these Optotrak files tend to have '#'s in the filenames
    % which MATLAB helpfully converts to '_', it also loses the extension, 
    % and replaces any otter dots with '_'
    [tmp1, dataName, tmp2] = fileparts (fullName);
    dataName = strrep (dataName, '#', '_');
    dataName = strrep (dataName, '.', '_');
    data = getfield (tmp, dataName);

    [numFrames, numChans] = size (data);
    % determine sampling rate
    FsStr = inputdlg ('Sample rate:', 'Sampling rate for data...', 1, {num2str(1000)});
    Fs = str2num (FsStr{1});

    % user will have to provide number of markers/dimensions; use this loop to ensure
    answer = inputdlg ({'No. of markers:', 'No. of dimensions (1-D, 2-D, 3-D):', 'First col/row is frame no. (y/n):'}, ...
        'Info on motion data:', 1, ...
        {num2str(floor(numChans/3)) num2str(3) 'n'});
    numMarkers = str2num (answer {1});
    numDims = str2num (answer {2});
    firstIsFrameNum = answer {3};
end

% lose first col if it's just the frame number
if (strncmp (firstIsFrameNum, 'y', length(firstIsFrameNum)))
    data (:, 1) = [];
end

% xData yData zData
xData = zeros (numFrames, numMarkers);
yData = zeros (numFrames, numMarkers);
zData = zeros (numFrames, numMarkers);
for index = 1:numMarkers
    oldIndex = (index - 1) * numDims + 1;
    xData (:, index) = data (:, oldIndex);
    if (numDims > 1)
        yData (:, index) = data (:, oldIndex + 1);
    end
    if (numDims > 2)
        zData (:, index) = data (:, oldIndex + 2);
    end
end

% dropouts!
threshold = 10000;
% too many dropouts means we lose the marker
theMarker = 1;
numMarkersDeleted = 0;
while (theMarker <= numMarkers)
    % how much data are allowed to be corrupt
    maxNumDrops = .8 * numFrames;
    numxDrops = length (find (abs (xData (:,theMarker)) > threshold));
    numyDrops = length (find (abs (yData (:,theMarker)) > threshold));
    numzDrops = length (find (abs (zData (:,theMarker)) > threshold));
    if (numxDrops > maxNumDrops | numyDrops > maxNumDrops | numzDrops > maxNumDrops)
        xData (:, theMarker) = [];
        yData (:, theMarker) = [];
        zData (:, theMarker) = [];
        numMarkersDeleted = numMarkersDeleted + 1;
        numMarkers = numMarkers - 1;
    else
        theMarker = theMarker + 1;
    end
end
xDrops = getdrops (xData, threshold);
yDrops = getdrops (yData, threshold);
zDrops = getdrops (zData, threshold);
drops = union (xDrops, yDrops);
drops = union (drops, zDrops);
xData = fixdrops (xData, drops, 'spline');
yData = fixdrops (yData, drops, 'spline');
zData = fixdrops (zData, drops, 'spline');

% tell user if dropouts fixed and/or markers removed
if (length (drops) > 0 | numMarkersDeleted > 0)
    msgString = sprintf ('Number of markers deleted: %d\nNumber of dropouts filled: %d', ...
        numMarkersDeleted, length(drops));
    msgbox (msgString, 'Data modified...');
end
