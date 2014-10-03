function excl_rad (tagPrefix)
% EXCL_RAD   Callback function to make radio buttons mutually exclusive
%   EXCL_RAD (TAGPREFIX) finds all radio buttons in a figure, and in a set whose
%   'Tag' property begins with the string TAGPREFIX, turns all off, except for the
%   one that was clicked.  For this to work properly, all radio buttons 'grouped' 
%   together must have tags that begin the same way, e.g., 'Radiobutton_Plot'.
%   Presumably, the remainder of the tags will be unique, e.g., 'Radiobutton_Plot1',
%   'Radiobutton_Plot2'.  EXCL_RAD uses the 'Min' and 'Max' properties of the button
%   that was clicked to set the 'Min' and 'Max' properties for the entire group.

% By: Ian Kremenic
% Last modified: 7.18.2001

% get all  radio buttons in figure
buttons = findobj (gcbf, 'Style', 'radiobutton');

% what are correct on/off settings for these buttons? (in case not 1/0)
on = get (gcbo, 'Max');
off = get (gcbo, 'Min');

% find the ones that are to be mutually exclusive; set them to 0
for i = 1:length (buttons),
    if (strncmp (get (buttons (i), 'Tag'), tagPrefix, length (tagPrefix))),
        set (buttons (i), 'Value', off);
    end
end

% set the one the was clicked to 1
set (gcbo, 'Value', on);

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