function savestats (data)
% SAVESTATS  Save data from user to a tab-delimited file.  
%   SAVESTATS (DATA) asks the user to specify a file, and 
%   saves the information in DATA to that file, in ASCII.  The 
%   file is created if it does not exist, or appended to if it 
%   is an existing file.

% By: Ian Kremenic
% Last modified: 6.27.2001

% get file name
[filename, pathname] = uiputfile ('*.*', 'Save to file...');
% check if user hit 'Cancel'
if (~filename)
   return;
end

% open file for appending
dataFile = fopen ([pathname filename], 'a');

% make format string
formatStr = '';
[numrows numcols] = size (data);		% might be a matrix
for index = 1:numcols
   formatStr = [formatStr '%9.5f\t'];
end
formatStr = [formatStr '\n'];

% write to file and close
fprintf (dataFile, formatStr, data);
fclose (dataFile)

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