function [startPt, endPt] = rb_startend
% RB_STARTEND  Pick start and end points of event using a rubber-band box.
%   When the user clicks on plot, use this as starting point, and start
%   drawing a rubber-band box.  When the user releases the mouse button,
%   use this as the last point.  The x-coords of start and end point are
%   returned.
%   [STARTPT ENDPT] = RB_STARTEND results in STARTPT containing the 
%   x-coord of the first point, while ENDPT has the second.
%
%   Superceded by RBBOX.

% by: Ian Kremenic
% Last modified: 7.12.99

% figure out start and end points using a rubber-band box
startPt = get (gca, 'CurrentPoint');
rbbox;
endPt = get (gca, 'CurrentPoint');
startPt = startPt (1, 1);     % check out the meaning of CurrentPoint for axes;
endPt = endPt (1, 1);         % we're only interested in x  

thePoints = [startPt endPt];	% this gets returned

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
