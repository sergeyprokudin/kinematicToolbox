function [data, Fs, chanLabel, chanUnits, numChans, numSamples, fullName] = loadacq (dataArch, fullName)
% LOADACQ   Load an Acqknowledge format file of analog data
%   [DATA, FS, CHANLABEL, CHANUNITS, NUMCHANS, NUMSAMPLES, FULLNAME] = LOADACQ 
%   prompts the user for the name of a data acquisition file to load.  It 
%   returns the data in the matrix DATA (one column per channel).  
%
%   FS is the rate at which data were sampled, CHANLABEL is a (text) label for
%   the channel, CHANUNITS is text for the units being measured on that 
%   channel (e.g., 'Volts'), NUMCHANS is the total number of channels, 
%   NUMSAMPLES is the number of samples per channel. 
%   FULLNAME is the path- and filename of the opened file.
%
%   LOADACQ (DATA_ARCH) performs the same function, but allows the user
%   to specify the architecture of the machine on which the data were 
%   collected (i.e., big- or little-endian).  If not specified, defaults
%   to big-endian (Mac).
%
%   LOADACQ (DATA_ARCH, FILENAME) loads data from the file FILENAME (note: it is
%   assumed that the path is contained in the filename).

% By: Ian Kremenic
% Last modified: 7.21.2000

% if called with no input args, we need to get a filename
%if (nargin == 0)
if (~exist ('fullName'))
    % get file name
	[filename, pathname] = uigetfile ('*.ad', 'Pick a data file to load...');
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
analogFile = fopen (fullName, 'r', dataArch);

% skip first two bytes, read file version, header length, and number of channels
fseek (analogFile, 2, 'bof');
temp = fread (analogFile, 2, 'long');

fileVersion = temp (1);
headerLength = temp (2);

numChans = fread (analogFile, 1, 'short');

% skip 4 bytes, read sampling time (msec / samp), convert to sampling freq
fseek (analogFile, 4, 'cof');
Fs = 1000 / (fread (analogFile, 1, 'float64'));

% skip past main header
fseek (analogFile, headerLength, 'bof');

% get channel info
for theChan = 1:numChans
	% get interesting stuff: header length for a channel, channel number,
	% channel label, number of samples
	chanHeaderLength (theChan) = fread (analogFile, 1, 'long');
	chanNumber (theChan) = fread (analogFile, 1, 'short');
	chanLabel (theChan, :) = setstr (fread (analogFile, 40, 'char')');
	fseek (analogFile, 22, 'cof');
	chanUnits (theChan, :) = setstr (fread (analogFile, 20, 'char')');
	chanSamples (theChan) = fread (analogFile, 1, 'long');
	chanAmpScale (theChan) = fread (analogFile, 1, 'float64');

	% that's all we need; go to the end of this channel
	bytesRead = 100;	% how many bytes did we read so far
	fseek (analogFile, chanHeaderLength (theChan) - bytesRead, 'cof');
end

% how many samples per channel? (assumption: all channels sampled at same rate)
numSamples = chanSamples (1);		% this gets returned

% read and skip creator specific header
temp= fread (analogFile, 2, 'short');
creatorHeaderLength = temp (1);
creatorHeaderType = temp (2);
fseek (analogFile, creatorHeaderLength - 4, 'cof');

% read data header.  consists of:
% - data size: size of each sample in bytes
% - dataType: 1->floating point (size is precision), 2->binary (size is word length)
for theChan = 1:numChans
	temp = fread (analogFile, 2, 'short');
	dataSize (theChan) = temp (1);
	dataType (theChan) = temp (2);
end

if (dataSize (1) == 1)
	dataType = 'char';
elseif (dataSize (1) == 2)
	dataType = 'short';
elseif ((dataSize (1) == 4) & (dataType (1) == 1))
	dataType = 'float32';
elseif ((dataSize (1) == 4) & (dataType (1) == 2))
	dataType = 'long';
elseif (dataSize (1) == 8)
	dataType = 'float64';
else
	disp ('I do not know how big the samples in the analog file are!');
	break;
end

% read all the data into a temp place; note that the channels are interleaved,
% so we'll have to deal with putting it in nice variables later
temp = fread (analogFile, numSamples * numChans (1), 'short');

% pre-allocate something to hold our data to speed things up
data = zeros (numSamples, numChans (1));

% fill data matrix, one column for each channel
% doing it column-wise makes it faster, for loop faster than while
for theSample = 1:numChans:chanSamples * numChans
	data (ceil (theSample / numChans), :) = temp (theSample:theSample + numChans - 1)';
end

% let's scale the data
for theChan = 1:numChans
	data (:, theChan) = data (:, theChan) * chanAmpScale (theChan);
end


% close file
fclose (analogFile);

disp ('Done loading analog data.')

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