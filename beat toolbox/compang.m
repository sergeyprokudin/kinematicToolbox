function theta = compang (varargin)
% COMPANG   Compute the (2-D or 3-D) angle created by a joint.
%   A function that takes 3-D data and computes the angle defined
%   by either three markers (points), or two lines/planes.  In the case
%   of three markers, it computes the angle between two lines
%   which are constructed by joining the points given by
%   the three markers.  To compute a 2-D angle, the plane 
%   in which to compute the angle is given by the final argument.
%   THETA = COMPANG (MARKER1, MARKER2, MARKER3) computes the
%   3-D angle between a line drawn from each point in MARKER1 and
%   MARKER2 and a line from MARKER2 to MARKER3.  The angle
%   is returned in the vector THETA.
%   THETA = COMPANG (MARKER1, MARKER2, MARKER3, VIEW) computes the
%   2-D angle between a line drawn from each point in MARKER1 and
%   MARKER2 and a line from MARKER2 to MARKER3 from the perspective
%   given by VIEW.  
%   THETA = COMPANG (LINE1, LINE2, VIEW) works analogously.
%   VIEW can be either 'xy' (x-y plane, top view in VScope parlance), 
%   'yz' (y-z plane, side view for VScope parlance), or 'xz' (x-z plane, 
%   front view for VScope).

% By: Ian Kremenic
% Last modified: 10.27.2000


switch (nargin)
% two args: two lines
case 2
   line1 = varargin{1};
   line2 = varargin{2};
   view = [];
% 3 args; two possibilities; if third is a string, then two lines, with
% third defining plane in which we want to view angle.  otherwise, we have three
% markers defining two lines
case 3
   if (ischar (varargin{3}))
      line1 = varargin{1};
      line2 = varargin{2};
      view = varargin{3};
   else
      line1 = varargin{1} - varargin{2};
      line2 = varargin{2} - varargin{3};
      view = [];
   end
% four args: 3 markers defining two lines, plus plane in which to view angle   
case 4
   line1 = varargin{1} - varargin{2};
   line2 = varargin{2} - varargin{3};
	view = varargin{4};   
end

% only need two dims. if we've defined a view; get rid of third
if (~isempty (view))
   switch (view)
   case 'yz'
      getRidOf = 1;		% y-z plane
   case 'xz'
      getRidOf = 2;		% x-z plane
   case 'xy'
      getRidOf = 3;		% x-y plane
   end
   line1 (:,getRidOf) = [];
   line2 (:,getRidOf) = [];
end

% make into 2-D coords by getting rid of unneeded dimension if we want 2-D angle
%if (nargin == 4)
%	if (strcmp (view, 'yz'))	% y-z plane
%		getRidOf = 1;
%	elseif (strcmp (view, 'xz'))	% x-z plane
%		getRidOf = 2;
%	elseif (strcmp (view, 'xy'))	% x-y plane
%		getRidOf = 3;
%	else
%		disp ('COMPANG ERROR: Can''t compute 2-D angle unless you enter correct view!')
%		return;
%	end
%	marker1 (:, getRidOf) = [];
%	marker2 (:, getRidOf) = [];
%	marker3 (:, getRidOf) = [];
%end

% compute the two lines
%line1 = marker1 - marker2;
%line2 = marker2 - marker3;

%%%%line1 = [marker1(:, 1)-marker2(:, 1) marker1(:, 2)-marker2(:, 2)];
%%%%line2 = [marker2(:, 1)-marker3(:, 1) marker2(:, 2)-marker3(:, 2)];

% compute angle
%theta = acos (dotprod (line1, line2) ./ (vectmag (line1) .* vectmag (line2)));
theta = acos (dot (line1', line2')' ./ (vectmag (line1) .* vectmag (line2)));
theta = theta * 180 / pi;	% convert from radians to degrees

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