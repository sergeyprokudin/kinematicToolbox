function [normData, normVals] = norm_emg (data, varargin)
% NORM_EMG  Normalize EMG using one of a bunch of methods

% By: Ian Kremenic
% Last modified: 7.20.2001

% make sure data either a matrix or column vector
if (size (data,1) == 1)
    data = data';
end
% we'll use these in a couple of places
[numrows, numcols] = size (data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% input args %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% can give a single value to which to normalize
% can give a signal; also need a time period then
% can give nothing; then normalize to max of current signal
if (nargin < 2)
    % no second arg; use max of each channel to normalize
    normVals = max (abs (data));
else
    if (nargin < 3)
        % no third arg; therefore second arg is max values for each channel
        normVals = varargin {1};
        % if only one number given, use it for each channel
        [maxrows, maxcols] = size (normVals);
        if (maxrows * maxcols == 1)
            normVals = normVals * ones (1, numcols);
        end
    else
        % second arg is data containing max contractions; third arg tells how much
        % of said data to use for a 'max'
        maxData = varargin {1};
        duration = varargin {2};
        % do we use all or just some?
        if (nargin < 4)
            % use all
            normVals = maxregion (maxData, duration);
        else
            % use some; exactly what 'some' is given by next two args
            startPt = varargin {3};
            endPt = varargin {4};
            normVals = maxregion (maxData, duration, startPt, endPt);
        end
    end
end

% make sure there's exactly one max for each channel
if (numcols ~= length (normVals))
    errordlg ('You must have one max value for each channel you wish to normalize.', ...
        'Error in NORM_EMG');
    return;
end
% make it easy to multiply matrices properly to get result
normData = data / diag (normVals);

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