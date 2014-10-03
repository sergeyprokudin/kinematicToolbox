function [data, Fs, chanLabel, chanUnits, numChans, numSamples, fullName] = loadnor (fullName)
% LOADNOR   Load a Noraxon MyoSoft file of analog data in ASCII format
%   [DATA, FS, CHANLABEL, CHANUNITS, NUMCHANS, NUMSAMPLES FULLNAME] = LOADNOR 
%   prompts the user for the name of a data acquisition file to load.  
%
%   It returns the data in the matrix DATA (one column per channel).  
%   FS is the rate at which data were sampled, CHANLABEL is a (text) 
%   label for the channel, CHANUNITS is text for the units being 
%   measured on that channel (e.g., 'Volts'), NUMCHANS is the total 
%   number of channels. NUMSAMPLES is the number of samples in each channel.  
%
%   FULLNAME is the path- and filname of the opened file.
%
%   LOADACQ (FILENAME) loads data from the file FILENAME (note: it is
%   assumed that the path is contained in the filename).
%
%   Support coming for MyoSoft's own format.

% By: Ian Kremenic
% Last modified: 7.21.2000

% stuff about the file format; Noraxon Winmyo ver. 3.4
FILE_EXT = '*.asc';			% extension of data files
FS_LABEL = 'Frequency';		% what is the label for sampling frequency?
DELIM = ':';					% what divides data from labels in file header?
CHAN_LABEL = 'Channel Labels';	% what is label for channel labels?

chanUnits = 'milliVolts';	% KLUDGE!!! KLUDGE!!! KLUDGE!!!

% if called with no input args, we need to get a filename
if (nargin == 0)
    % get file name
	[filename, pathname] = uigetfile (FILE_EXT, 'Pick a data file to load...');
	if (filename == 0)
		break;
	end
	fullName = [pathname filename];
end

% open file
analogFile = fopen (fullName, 'r');

% suck in the header, until we hit the smapling frequency
while (1)
	theLine = fgets (analogFile);
   [label, data] = strtok (theLine, DELIM);
   if (strncmp (label, FS_LABEL, length (FS_LABEL)))
      break;
   end
end

% grab sampling frequency
[crud, FsStr] = strtok (data);		% sampling freq. is stuff after colon and space
Fs = str2num (FsStr);					% this gets returned

% suck in more header, until we hit channel labels
while (1)
	theLine = fgets (analogFile);
   if (strncmp (theLine, CHAN_LABEL, length (CHAN_LABEL)))
      break;
   end
end

% next lines are channel labels
theChan = 0;
chanLabel = [];
while (1)
   theLine = fgetl (analogFile);			% get string w/o line terminator
   [chanNum, label] = strtok (theLine, DELIM);	% split at colon
   if (isempty (label))						% no colon: blank line, data follow
      break;									% so break out of this loop
   end
   theChan = theChan + 1;					% be careful where this goes!
   [crud, label] = strtok (label);		% label is after colon and space
   %   chanLabel (theChan, :) = label;		% this gets returned
   chanLabel = strvcat (chanLabel, deblank (label));
												   % don't deblank label!--could make them
												   % each label unequal in length
end
numChans = theChan;			% this gets returned

% data, at last; read it all in, it's just columns of numbers
% format of string to read
theFormat = '';
for index = 1:numChans
   theFormat = [theFormat '%d '];
end
data = fscanf (analogFile, theFormat, [numChans inf]);
data = data';				% transpose for proper arrangement of data

% how many samples in each channel?
[numSamples, numcols] = size (data);		% numSamples gets returned

fclose (analogFile);

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