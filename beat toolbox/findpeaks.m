function [ind,peaks] = findpeaks(y, threshold, duration)
% FINDPEAKS  Find peaks in real vector.
%   ind = findpeaks(y) finds the indices (ind) which are
%   local maxima in the sequence y.  For local minima, use
%   FINDPEAKS (-Y).
%
%   [ind,peaks] = findpeaks(y) returns the value of the peaks at 
%   these locations, i.e. peaks=y(ind);
%
%   FINDPEAKS (Y, THRESHOLD) performs the same opration, but will
%   only return peaks larger than THRESHOLD.
%
%   FINDPEAKS (Y, THRESHOLD, DURATION) will only find peaks separated by
%   at least DURATION points.
%
%   Originally posted to comp.soft-sys.matlab 12.16.1996 by 
%   Tom Krauss (krauss@mathworks.com)
%
%   Modified 6.27.2001 by Ian Kremenic (ian@nismat.org) to also
%   use optional threshold.
% 
% Last modified: 9.28.2001

if (nargin < 2 | isempty (threshold))
    threshold = min (y);
end

if (nargin < 3)
    duration = 0;
end

y = y(:)';

dy = diff(y);

ind = find( ([dy 0]<0) & ([0 dy]>=0) & (y>=threshold));

% don't want endpoints; must make sure that ind is not empty!
if (~isempty (ind) & ind (1) == 1)
    ind (1) = [];
end
%if (y(end-1)<y(end) & (y(end)>threshold))
%    ind = [ind length(y)];
%end

% make sure all points are at least DURATION apart
if (duration ~= 0)
    index = 1;
    while (index < length (ind))
        tooClose = find (ind (index+1:end) < ind (index) + duration);
        ind (tooClose+index) = [];
        index = index + 1;
    end
end

if nargout > 1
    peaks = y(ind);
end

%+=== Tom Krauss ========================= krauss@mathworks.com ===+
%|    The MathWorks, Inc.                    info@mathworks.com    |
%|    24 Prime Park Way                http://www.mathworks.com    |
%|    Natick, MA 01760-1500                   ftp.mathworks.com    |
%+=== Tel: 508-647-7346 ==== Fax: 508-647-7002 ====================+

