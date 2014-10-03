
function [data, Fs, chanLabels, chanUnits, numChans, numSamples, filename]=loadlabview(filename)
% LOADLABVIEW   Load a binary Labview file of analog data.
%   [DATA, FS, CHANLABEL, CHANUNITS, NUMCHANS, NUMSAMPLES, FULLNAME] = 
%       LOADLABVIEW
%   prompts the user for the name of a data acquisition file to load.  It 
%   returns the data in the matrix DATA (one column per channel).  
%
%   FS is the rate at which data were sampled, CHANLABEL is a (text) label for
%   each channel, CHANUNITS is text for the units being measured on that 
%   channel (e.g., 'Volts'), NUMCHANS is the total number of channels, 
%   NUMSAMPLES is the number of samples per channel. 
%   FULLNAME is the path- and filename of the opened file.
%
%   LOADLABVIEW (FILENAME) loads data from the file FILENAME (note: it is
%   assumed that the path is contained in the filename).
%
%   Need to add functionality to specify data acquisition architecture
%   (i.e., PC or mac)?
%
%   Note: does not currently read file headers.  Dummy channel names are used,
%   units are assumed volts.  The user is prompted to enter a sampling frequency.
%
%	Orgiginally by: Ali Sheikhzadeh
%	    June 1994 
%
%   Modified by Ian Kremenic (ian@nismat.org) 
%   Last modified: 6.18.2001 

if (nargin == 0)
   [filename, pathname] = uigetfile ('*.*');
   filename = [pathname filename];
end

% Read bianry files
	fid=eval(['fopen(''' filename ''',''r'',''b'')''']);
if fid==0 disp(['ERROR: Problem with the file path'])
end
% Reading header size
	header=fread(fid,4,'uchar');
	headersize=(header(1)*256^3)+(header(2)*256^2)+(header(3)*256^1)+header(4);
% Reading the chan info
 	header=fread(fid,4,'uchar');
	chansize=(header(1)*256^3)+(header(2)*256^2)+(header(3)*256^1)+header(4);
% reading channaels
	a=fread(fid,chansize,'uchar');
	channels=(setstr(a)');
%disp(['Channels used:  ',channels])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Counting the number of channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[chan_size,jjj]=size(channels');
NumberofChan=0;
h=0;
for i=1:chan_size
	if channels(i)~=',' & i~=chan_size
		h=h+1;
	elseif  h >= 2 
			if i==chan_size
				k=0;
			else
				k=1;
			end
		 nn=channels(i-h:i-k);
		[jj,jjj]=size((str2num(nn))');	     
		NumberofChan=NumberofChan+jj;
		h=0;
	elseif  h < 2 
		NumberofChan=NumberofChan+1;
		h=0;
	end
end
%disp(['Total number of channels:   ',num2str(NumberofChan)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reading the configuration of data and moving to the next part
 	header=fread(fid,4,'uchar');
	config=(header(1)*256^3)+(header(2)*256^2)+(header(3)*256^1)+header(4);
move=4+4+4+config+chansize;
fseek(fid,move,'bof');
% Reading the user header
	scan_rate=fread(fid,4,'uchar');
% Reading the interchannel_delay
	interchannel_delay=fread(fid,4,'uchar');
% Reading the user_header
	move=4+4+config+chansize+8;
	move1=headersize-move;
	user_header=fread(fid,move1,'uchar');
	user_header=(setstr(user_header))';
%disp(['User header:  ',user_header])
%
	fseek(fid,(headersize+4),'bof');
% Reading data
		[data,dd]=fread(fid,[NumberofChan,inf],'short');
%
data=data';
data=data*2.44141E-3;
b=size(data);
numChans = NumberofChan;
numSamples = b (1);
% determine sampling rate
FsStr = inputdlg ('Sample rate:', 'Sampling rate for data...', 1, {num2str(1000)});
Fs = str2num (FsStr{1});
chanUnits = 'Volts';
chanLabels = [];
for i = 1:numChans
    chanLabels = strvcat (chanLabels, ['Channel ' num2str(i)])
end
%disp(['Size of imported matrix:  ','[',num2str(b(1)),'X',num2str(b(2)),']'])
fclose(fid);

% Part of the BEAT Toolbox.
% Copyright (C) 2001 Nicholas Institute of Sports Medicine and Athletic Trauma
% and Ali Sheikhzadeh
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