function [data, numButtons, sampInt, buttons, filename] = loadvsa
% LOADVSA   A function that loads a .VSA type data file obtained from the Vscope system.
%[DATA, NUMBUTTONS, SAMPINT, BUTTONS, FILENAME] = LOADVSA
%   prompts the user for a file to load (from a standard file 
%   open dialog).  The file is assumed to end in '.vsa'.  
%
%   Irrelevant header info is stripped off.  The function returns:
%
%      NUMBUTTONS: the number of Vscope buttons acquired
%      SAMPINT: the sampling interval (in msec., per button)
%      DATA: A matrix containing all the data acquired.  Each row 
%           contains x-, y-, and z-coordinates for each button 
%          (thus, data will have 3 * numButtons columns).
%      BUTTONS: the names of the buttons (e.g., 'green')
%      FILENAME: the name of the file loaded
%
%   LOADVSA will also fix dropouts in the file.

% By: Ian Kremenic
% Last modified: 7.21.2000

% get the data file
disp ('Starting...')
[filename, pathname] = uigetfile ('*.vsa', 'Pick a data file to load...');
if (filename == 0)
	break;
end
fullName = [pathname filename];		% make full file name
file = fopen (fullName, 'r');		% open for reading

% read the first few lines (header) of the file.  save any relevant info.
% we know that we're about to hit data when we hit a line composed of '-'
% and space characters.
% first define some constant strings to look for
colors = ['Yellow '; ...
	'Green  '; ...
	'Blue   '; ...
	'Red    '; ...
	'Cyan   '; ...
	'Magenta'; ...
	'White  '; ...
	'Grey   '];
size (colors);
numColors = 8;
numButStr = 'Number of Buttons = ';
sampIntStr = 'Sampling period = ';
line = ' ';
while (line (1) ~= '-')
	line = fgets (file);
	if (~isempty (findstr (line, numButStr)))
		numButPos = length (numButStr);
		numButTemp = line (numButPos:length (line));
		numButtons = str2num (strtok (numButTemp));
	elseif (~isempty (findstr (line, sampIntStr)))
		sampIntPos = length (sampIntStr);
		sampIntTemp = line (sampIntPos:length (line));
		sampInt = str2num (strtok (sampIntTemp));
	else
		theButton = 1;
		for theColor = 1:numColors
			if (~isempty (findstr (line, colors (theColor, :))))
				buttons (theButton, :) = colors (theColor, :);
				theButton = theButton + 1;
			end
		end
	end
end

% everything else in the file is data.  so we'll get it, get rid of the first
% column (this is sample time), and return the xyz data.
data = fscanf (file, '%f %f %f %f %f %f %f %f %f %f', [3*numButtons+1 inf]);

% reshape data into proper order (transpose) and get rid of extraneous data
data = data';
data (:, 1) = [];

% close that data file
fclose (file);

% fix those dropouts
DROPOUT = 35535;			% a dropout has this value
[x, y] = find (abs (data) >= (.8 * DROPOUT));	% NOTE: the .3 is good for our current
																% setup; for previous setup, use .7-.8
theBar = waitbar (0, 'Fixing dropouts...');
i = 1;
numDropOuts = length (x);
while (i <= numDropOuts)
   numPoints = 3;
   filtStart = x (i) - 1;
   if (i < numDropOuts)			% don't do this for the last drop out
	   while ((x (i) + 1 == x (i + 1)) & (y (i) == y (i + 1)))
		   if (i < numDropOuts - 1)			% don't do this for the last drop out
            i = i + 1;
            %disp (['LOOP: i = ' num2str(i)])
            numPoints = numPoints + 1;
         else
            break
         end
      end
   end
   filtEnd = x (i) + 1;
   data (filtStart:filtEnd, y (i)) = ...
      linspace (data (filtStart, y(i)), data (filtEnd, y (i)), numPoints)';
%   data (x (i), y (i)) = data (x (i) - 1, y (i));		% just set it equal to the prev. guy

   waitbar (i / numDropOuts);
   i = i + 1;
end

close (theBar)

% let the user know what happened
buttonStr = ['  ' num2str(numButtons) ' buttons'];
sampStr = ['  ' num2str(sampInt) ' msec. per button'];
[numrows numcols] = size (data);
dataStr = ['  ' num2str(numrows) ' points'];
dropOutStr = ['  ' num2str(numDropOuts) ' drop outs fixed'];
msgbox (char ('Data Loaded Successfully...', ...
   		['  ' filename], buttonStr, sampStr, dataStr, dropOutStr), 'FYI', 'help');


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