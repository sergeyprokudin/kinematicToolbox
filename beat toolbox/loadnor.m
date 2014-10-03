function [data, Fs, chanLabel, chanUnits, numChans, numSamples, fullName] = loadnor (format, varargin)
% LOADNOR   Load a Noraxon MyoSoft file of analog data in ASCII or binary format
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
%   LOADNOR (FILENAME) loads data from the file FILENAME (note: it is
%   assumed that the path is contained in the filename).
%
%   Now supports MyoSoft's binary format in a very MyoSoft-like interface.

% By: Ian Kremenic
% Last modified: 2.2.2001

if (nargin == 0)
    format = 'ascii';
end

% what kind of data file: ascii or straight from MyoSoft?
switch format
case 'ascii'
    %%%%%%%%%%%%%%%%%%%%%%%% ascii %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % stuff about the file format; Noraxon Winmyo ver. 3.4
    FILE_EXT = '*.asc';			% extension of data files
    FS_LABEL = 'Frequency';		% what is the label for sampling frequency?
    DELIM = ':';					% what divides data from labels in file header?
    CHAN_LABEL = 'Channel Labels';	% what is label for channel labels?
    
    chanUnits = 'microVolts';	% KLUDGE!!! KLUDGE!!! KLUDGE!!!
    
    % 2nd input arg should be filename; if not, prompt for it
    if (nargin < 2)
        % get file name
        [filename, pathname] = uigetfile (FILE_EXT, 'Pick a data file to load...');
        if (filename == 0)
            break;
        end
        fullName = [pathname filename];
    else
        fullName = varargin {1};
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
    
case 'myosoft'
    %%%%%%%%%%%%%%%%%% data straight from myosoft %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % define constants
    VAR_EXIST = 1;          % used by MATLAB to indicate that variable exists
    FILE_EXIST = 2;         % used by MATLAB to indicate that file exists
    DIR_EXIST = 7;          % used by MATLAB to indicate that directory exists
    LIST_FILENAME = 'list.ndx';     % file containing list of tests
    STRUCT_FILENAME = 'struct.ndx'; % file linking test name to file name
    TESTNAME_LEN = 20;      % length of a test name in MyoSoft files
    FILENAME_LEN = 13;      % length of a file name in MyoSoft files
    
    if (nargin < 2)
        theDir = pwd;
        startDir = '.';
    else
        startDir = varargin {1};
        theDir = fullfile (pwd, startDir);
    end
    
    % get directory listing; pull out directories only
    dirs = [];
    listing = dir (theDir);
    areDirs = find ([listing.isdir]);
    dirs = strvcat (listing(areDirs).name);
    dirs = sortrows(dirs);
    % add brackets to differentiate dirs from files
    dirs = strcat ('[', dirs, ']');
    
    % is there a list.ndx file?  if so, display tests
    listFile = fullfile (theDir, LIST_FILENAME)
    if (exist (listFile) == FILE_EXIST)
        LIST_FILE = fopen (listFile);
        % looks like list.ndx is sorted already, so we won't bother to sort
        fileList = fscanf (LIST_FILE, '%20c', [20 inf])';
        fclose (LIST_FILE);
    end
    listStr = cellstr (strvcat (fileList, dirs));
    done = 0;
    while (~done)
        % display dialog
        [selection, ok] = listdlg (...
            'PromptString', 'Select MyoSoft data file...', ...
            'SelectionMode', 'Single', ...
            'ListString', listStr)
        % cancel button presed; exit
        if (~ok)
            disp ('no file selected...');
            break;
        end
        % for a directory, remember to remove brackets
        nextDir = fullfile (startDir, listStr{selection}(2:end-1));
        if (exist (nextDir) == DIR_EXIST)
            % browse next dir by recursing
            [data, Fs, chanLabel, chanUnits, numChans, numSamples, fullName] ...
                = loadnor ('myosoft', nextDir);
            % once we've returned from recursion, well, return...
            return;
        end
        % here, we've got a file; display info
        structFile = fullfile (startDir, STRUCT_FILENAME);
        STRUCT_FILE = fopen (structFile);
        structStuff = fscanf (STRUCT_FILE, '%c', inf);
        fclose (STRUCT_FILE);
        % find test name in file
        filenameIndex = findstr (structStuff, listStr{selection});
        % offset from there to start of filename
        filenameIndex = filenameIndex + TESTNAME_LEN;
        filename = structStuff (filenameIndex:filenameIndex + FILENAME_LEN - 1);
        
        filename = fullfile (startDir, filename);
        [ptInfo, params, dataStart] = loadmyohdr (filename);
        % display info
        infoStr = strvcat (...
            ['Last name:   ' ptInfo.lastName], ...
            ['First name:  ' ptInfo.firstName], ...
            ['Test number: ' num2str(ptInfo.testNum)], ...
            ['Age:         ' ptInfo.age], ...
            ['Height:      ' ptInfo.height], ...
            ['Weight:      ' ptInfo.weight], ...
            ['Exercise:    ' ptInfo.exercise], ...
            ['Date/time:   ' ptInfo.dateTime], ...
            ['Samp freq.:  ' num2str(params.sampFreq)], ...
            ['Test duration: ' num2str(params.duration)], ...
            ['Total samples: ' num2str(params.numSamplesTotal)], ...
            ['Samples/chan:  ' num2str(params.numSamples)], ...
            ['# of channels.:  ' num2str(params.numChans)], ...
            ['Gender:         ' ptInfo.gender], ...
            ['Filename:     ' filename]);
        chanNames = ptInfo.muscleList (1:params.numChans, :);
        infoStr = strvcat (infoStr, ...
            'Muscles:', ...
            strcat ('....', chanNames));
        
        theButton = questdlg (infoStr, 'File info...');
        if (strcmp (theButton, 'Yes'))
            % yes, this is the file; load it
            done = 1;
        elseif (strcmp (theButton, 'Cancel'))
            % cancel; just return
            return;
        else
            % no, it ain't the file; gimme that dialog again
        end
        
    end
    % now, we have the header, let's read the data
    % open file
%    filename
    DATA_FILE = fopen (filename, 'r', 'l');     % acquired on Intel, so little-endian
    
    % go to start of data
    fseek (DATA_FILE, dataStart, 'bof');
    % read data into temp place; channels are interleaved, so we'll have to
    % arrange it properly later
    data = fread (DATA_FILE, params.numSamplesTotal, 'int16');
    fclose (DATA_FILE);
    % pre-allocate something to hold data
    data = reshape (data, params.numChans, params.numSamples)';
    
    % put things where they belong for return
    Fs = params.sampFreq;
    chanLabel = ptInfo.muscleList (1:params.numChans, :);
    chanUnits = params.chanUnits (1:params.numChans, :);
    numChans = params.numChans;
    numSamples = params.numSamples;
    fullName = filename;
    %plot (data)    
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