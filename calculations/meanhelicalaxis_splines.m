function [meanUnitVectorOutliersRemovedFinal, pivotPointOutliersRemovedFinal, unitVectorArrayOutliersRemovedFinal, pointArrayOutliersRemovedFinal, IHAIndex] = meanhelicalaxis_splines(parentCoords, childCoords, sampleRate, threshold, overlap, orientationOutlierThreshold, positionOutlierThreshold)

close all
% function [meanUnitVector, pivotPoint, unitVectorArray, pointArray] = ...
%     meanhelicalaxis(parentCoords, childCoords,sampleRate,threshold, 
%     overlap);
%     
%
% MEANHELICALAXIS calculates instantaneous helical axes using the technique
% described by Stokdijk et al. (1999). ClinBiomech, 14 , 177-84.
%
% PARENTCOORDS and CHILDCOORDS are 2-D arrays built columnwise with the x,
% y, z coordinates of markers attached to the parent and child segments
% respectively. The rows of PARENTCOORDS and CHILDCOORDS represent time.
%
% SAMPLERATE is the sampling frequenzy (HZ) of your data 
%
% THRESHOLD is a scalar that defines the minimum rotation over which the
% instantaneous helical axes are defined as valid. 
%
% OVERLAP is a string constant ('y' or 'n') that defines whether or not
% instantaneous helical axes are calculated from overlapping sections of
% the time history. 
%  
% ORIENTATIONOUTLIERTHRESHOLD & POSITIONOUTLIERTHRESHOLD specifiy removing 
% outlying IHAs (scalar). These thresholds correspond to the maximum
% allowable Pythagorean difference (in standard deviations) of the 
% orientation and position (of % the z = 0 intersect) of the IHAs from the 
% MHA. Once outliers have been removed, the MHA is recalculated.

%
% MEANHELICALAXIS calls the following custom functions: screw, soder &
% segmentorientation2

% Version 1 by:        Thor Besier
% Current version by:  Peter Mills (pmills@cyllene.uwa.edu.au)
% Last modified:       3 September, 2004

% Modified by David Saxby, david.saxby@griffithuni.edu.au
% Modified by James Dunne, james.dunne@stanford.edu

%   Check input arguments
if nargin < 3
    error('The first three input arguements are required');
elseif nargin == 3
    positionOutlierThreshold = 9999;
    positionOutlierThreshold = 9999;
    threshold = 10;
    overlap='y';
    orientationOutlierThreshold=9999;
elseif nargin == 8
    positionOutlierThreshold = 9999;
end
    
[nRows, nCols] = size(parentCoords);
nMarkers = nCols/3;

%%   Preallocate and define arrays and constants
unitVectorArray = [];
pointArray = [];
nIHAs = 0;
intersect = 3;  %   Location of the screw axis where it intersects
% either the x=0 (intersect=1), the y=0 (intersect=2), or the z=0
% (intersect=3) plane.

%% Set the Increments that the IHA calculation uses based on the sampleRate

if sampleRate <= 100
    increment =1;
elseif sampleRate <=250
    increment = 10;
else 
    increment = 20;
end


%%  Calculate IHAs using userdefined rotation threshold and logical 
%   loop (while) to perform IHA calculations with or without overlapping
%   segments

currentIndex = increment; % Initialise currentindex    
IHAcount = 1;
i = 1;
% Start logical loop (while)
while i + currentIndex <= nRows
    
   % Create a matrix of two rows that show the coodinates at time=i and 
   % time=i+currentIndex
    childMarkerInput = [childCoords(i,:); childCoords(i + currentIndex,:)];
    
    % Calculate transformation matrix for child segment using 'svd'
    % SODER calculates the transformation matrix T containing
    % the rotation matrix (3x3) and the translation translation 
    % vector d (3x1) for a rigid body segment using a singular
    % value decomposition method (Soederkvist & Wedin 1993).
    [T, res] = soder(childMarkerInput);
    [unitVector, point, phi, t] = screw(T, intersect);
    
    % Calculation of the screw axis
    if unitVector(3) < 0
        unitVector = -unitVector;
    end
    
    % Only use helical axes that are predicted with phi greater than
    % predefined 'threshold' degrees. If abs(phi) < threshold is true then
    % an increment will be added onto the currentindex and the loop begins
    % again. If false the unit vector is passed as an IHA
    if abs(phi) < threshold
        currentIndex = currentIndex + increment;
    else
        % Append to IHA unit vector and point arrays
        IHAIndex(IHAcount) = currentIndex;
        IHAcount = IHAcount + 1;
        unitVectorArray = [unitVectorArray; unitVector'];
        pointArray = [pointArray; point'];

        if overlap == 'y'
            i = i + increment;
        else
            i = i + currentIndex;
        end
        currentIndex = currentIndex + increment;
        nIHAs = nIHAs + 1;
    end
end

IHAIndex = find(IHAIndex > -9999999999999999999);

%% Calculate mean helical axis using entire array
%Preallocate and define arrays
I = eye(3,3);
q = zeros(3,3);
qSum= zeros(3,3);
qUnitVector = zeros(3,1);
qPointSum = zeros(3,1);
halfKneeWidth = 50; % Estimate for plotting purposes

for i = 1:nIHAs
    q = I - unitVectorArray(i,:)' * unitVectorArray(i,:);
    %qUnitVector = q * unitVectorArray(i,:)';
    qPoint = q * pointArray(i,:)';
    qSum = q + qSum;
    qPointSum = qPoint + qPointSum;
end

%  Calculate unit vector and pivot point that define mean helical axis
qPointMean = qPointSum/nIHAs;
qMean = qSum/nIHAs;
meanUnitVector = mean(unitVectorArray)';
pivotPoint = inv(qMean) * qPointMean;
% pivotPoint = qMean/qPointMean; % improvement over inv() function.

%  Extrapolate axis to approximately the width of knee joint (100 mm)
MHAextrapolationVector = (halfKneeWidth/ meanUnitVector(1))* meanUnitVector;
MHA1 = pivotPoint - MHAextrapolationVector;
MHA2 = pivotPoint + MHAextrapolationVector;
MHAOutliersIncluded = [MHA1 pivotPoint MHA2];

%% Calculate rms deviation of individual unit vectors and points from mean
pointError = sqrt((mean(pointArray(:,2)) - pointArray(:,2)).^2 + ...
    (mean(pointArray(:,3)) - pointArray(:,3)).^2);
meanPointError = mean(pointError);
stdPointError = std(pointError);

orientationError = real(acos(unitVectorArray/meanUnitVector'));
meanOrientationError = mean(orientationError);
stdOrientationError = std(orientationError);

%% Remove IHAs that have orientation and/or position deviations from mean
%% greater than used defined thresholds (scalar * sd) 
index = 1;
invalidIHA = [];
for i = 1:nIHAs
    if orientationError(i) > meanOrientationError + orientationOutlierThreshold...
            * stdOrientationError || pointError(i) >...
            meanPointError + positionOutlierThreshold * stdPointError
        invalidIHA(index) = (i);
        index = index + 1;
        IHAIndex(i) = NaN;
    end
end

IHAIndex = find(IHAIndex > -9999999999999999999);

validi = 1;
invalidi = 1;
for i = 1:nIHAs
    if isempty(findstr(i, invalidIHA));
        unitVectorArrayOutliersRemoved1stPass(validi, :) = unitVectorArray(i, :);
        pointArrayOutliersRemoved1stPass(validi, :) = pointArray(i, :);
        validi = validi + 1;
    else
        unitVectorArrayOutliers1stPass(invalidi, :) = unitVectorArray(i, :);
        pointArrayOutliers1stPass(invalidi, :) = pointArray(i, :);
        invalidi = invalidi + 1;
    end
end

%% Define IHAs that are not outliers (1st pass)
nValidIHAs1stPass = size(pointArrayOutliersRemoved1stPass,1);
for i = 1:nValidIHAs1stPass
    IHAextrapolationVector = ...
        (halfKneeWidth/unitVectorArrayOutliersRemoved1stPass(i,1))...
        * unitVectorArrayOutliersRemoved1stPass(i,:)';
    IHA1 = pointArrayOutliersRemoved1stPass(i,:)' - IHAextrapolationVector;
    IHA2 = pointArrayOutliersRemoved1stPass(i,:)' + IHAextrapolationVector;
    IHAMinusOutliers1stPass = [IHA1 pointArrayOutliersRemoved1stPass(i,:)' IHA2];
end

%%   If no IHAs are outside the mean +- positionOutlierThreshold or 
% orientationOutlierThreshold * SD then define the output arguements based 
% on 1st pass
if size(invalidIHA,1) == 0
   I = eye(3,3);
    q = zeros(3,3);
    qSum= zeros(3,3);
    qPointSum = zeros(3,1);
    for i = 1:nValidIHAs1stPass
        q = I - unitVectorArrayOutliersRemoved1stPass(i,:)' * unitVectorArrayOutliersRemoved1stPass(i,:);
        qPoint = q * pointArrayOutliersRemoved1stPass(i,:)';
        qSum = q + qSum;
        qPointSum = qPoint + qPointSum;
    end
   %  Calculate unit vector and pivot point that define mean helical axis
    qPointMean = qPointSum/nValidIHAs1stPass;
    qMean = qSum/nValidIHAs1stPass;
    
    unitVectorArrayOutliersRemovedFinal = unitVectorArrayOutliersRemoved1stPass;
    pointArrayOutliersRemovedFinal = pointArrayOutliersRemoved1stPass;
    meanUnitVectorOutliersRemovedFinal = mean(unitVectorArrayOutliersRemoved1stPass)';
    pivotPointOutliersRemovedFinal = inv(qMean) * qPointMean;
    return
end

%% Define IHA outliers (1st pass)
nInvalidIHAs1stPass = size(pointArrayOutliers1stPass,1);
for i = 1:nInvalidIHAs1stPass
    IHAextrapolationVector = ...
        (halfKneeWidth/unitVectorArrayOutliers1stPass(i,1)) * ...
        unitVectorArrayOutliers1stPass(i,:)';
    IHA1 = pointArrayOutliers1stPass(i,:)' - IHAextrapolationVector;
    IHA2 = pointArrayOutliers1stPass(i,:)' + IHAextrapolationVector;
    IHAOutliers1stPass = [IHA1 pointArrayOutliers1stPass(i,:)' IHA2];
end

%%   Recalculate mean helical axis with outliers removed
I = eye(3,3);
q = zeros(3,3);
qSum= zeros(3,3);
qPointSum = zeros(3,1);

% OPTIONAL: Required for calculation of mean helical axis           [START]
for i = 1:nValidIHAs1stPass
    q = I - unitVectorArrayOutliersRemoved1stPass(i,:)' * unitVectorArrayOutliersRemoved1stPass(i,:);
    qPoint = q * pointArrayOutliersRemoved1stPass(i,:)';
    qSum = q + qSum;
    qPointSum = qPoint + qPointSum;
end

%  Calculate unit vector and pivot point that define mean helical axis
qPointMean = qPointSum/nValidIHAs1stPass;
qMean = qSum/nValidIHAs1stPass;
meanUnitVectorOutliersRemoved1stPass = mean(unitVectorArrayOutliersRemoved1stPass)';
pivotPointOutliersRemoved1stPass = inv(qMean) * qPointMean;
% OPTIONAL: Required for calculation of mean helical axis             [END]

%%  Extrapolate axis to approximately the width of knee joint (100 mm)
MHAextrapolationVector = (halfKneeWidth/ meanUnitVectorOutliersRemoved1stPass(1))* meanUnitVectorOutliersRemoved1stPass;
MHA1 = pivotPointOutliersRemoved1stPass - MHAextrapolationVector;
MHA2 = pivotPointOutliersRemoved1stPass + MHAextrapolationVector;
MHAOutliersRemoved1stPass = [MHA1 pivotPointOutliersRemoved1stPass MHA2];

%% Calculate rms deviation of individual unit vectors and points from mean
% after first wave of outliers removed
pointError = sqrt((mean(pointArrayOutliersRemoved1stPass(:,2)) - pointArrayOutliersRemoved1stPass(:,2)).^2 + ...
    (mean(pointArrayOutliersRemoved1stPass(:,3)) - pointArrayOutliersRemoved1stPass(:,3)).^2);
meanPointError = mean(pointError);
stdPointError = std(pointError);

orientationError = real(acos(unitVectorArrayOutliersRemoved1stPass/meanUnitVector'));
meanOrientationError = mean(orientationError);
stdOrientationError = std(orientationError);

%% Remove IHAs that have orientation and/or position deviations from mean
%% greater than used defined thresholds (scalar * sd) 
index = 1;
for i = 1:nValidIHAs1stPass
    if orientationError(i) > meanOrientationError + orientationOutlierThreshold...
            * stdOrientationError || pointError(i) >...
            meanPointError + positionOutlierThreshold * stdPointError
        invalidIHAFinal(index) = (i);
        index = index + 1;
        IHAIndex(i) = NaN;
    end
end

IHAIndex = find(IHAIndex > -9999999999999999999);

validi = 1;
invalidi = 1;
for i = 1:nValidIHAs1stPass
    if isempty(findstr(i, invalidIHAFinal));
        unitVectorArrayOutliersRemovedFinal(validi, :) = unitVectorArrayOutliersRemoved1stPass(i, :);
        pointArrayOutliersRemovedFinal(validi, :) = pointArrayOutliersRemoved1stPass(i, :);
        validi = validi + 1;
    else
        unitVectorArrayOutliersFinal(invalidi, :) = unitVectorArrayOutliersRemoved1stPass(i, :);
        pointArrayOutliersFinal(invalidi, :) = pointArrayOutliersRemoved1stPass(i, :);
        invalidi = invalidi + 1;
    end
end

%% Define IHAs that are not outliers (2nd pass) outliers
nValidIHAsFinal = size(pointArrayOutliersRemovedFinal,1);
for i = 1:nValidIHAsFinal
    IHAextrapolationVector = ...
        (halfKneeWidth/unitVectorArrayOutliersRemovedFinal(i,1))...
        * unitVectorArrayOutliersRemovedFinal(i,:)';
    IHA1 = pointArrayOutliersRemovedFinal(i,:)' - IHAextrapolationVector;
    IHA2 = pointArrayOutliersRemovedFinal(i,:)' + IHAextrapolationVector;
    IHAMinusOutliersFinal = [IHA1 pointArrayOutliersRemovedFinal(i,:)' IHA2];
end

%%   Recalculate mean helical axis with outliers removed
I = eye(3,3);
q = zeros(3,3);
qSum = zeros(3,3);
qPointSum = zeros(3,1);

% OPTIONAL: Required for calculation of mean helical axis           [START]
for i = 1:nValidIHAsFinal
    q = I - unitVectorArrayOutliersRemovedFinal(i,:)' * unitVectorArrayOutliersRemovedFinal(i,:);
    qPoint = q * pointArrayOutliersRemovedFinal(i,:)';
    qSum = q + qSum;
    qPointSum = qPoint + qPointSum;
end

%  Calculate unit vector and pivot point that define mean helical axis
qPointMean = qPointSum/nValidIHAsFinal;
qMean = qSum/nValidIHAsFinal;
meanUnitVectorOutliersRemovedFinal = mean(unitVectorArrayOutliersRemovedFinal)';
pivotPointOutliersRemovedFinal = inv(qMean) * qPointMean;
% OPTIONAL: Required for calculation of mean helical axis             [END]

%%  Extrapolate axis to approximately the width of knee joint (100 mm)
MHAextrapolationVector = (halfKneeWidth/ meanUnitVectorOutliersRemovedFinal(1))* meanUnitVectorOutliersRemovedFinal;
MHA1 = pivotPointOutliersRemovedFinal - MHAextrapolationVector;
MHA2 = pivotPointOutliersRemovedFinal + MHAextrapolationVector;
MHAOutliersRemovedFinal = [MHA1 pivotPointOutliersRemovedFinal MHA2];

%% Define IHA outliers (2nd pass)
nInvalidIHAsFinal = size(pointArrayOutliersFinal,1);
for i = 1:nInvalidIHAsFinal
    IHAextrapolationVector = ...
        (halfKneeWidth/unitVectorArrayOutliersFinal(i,1)) * ...
        unitVectorArrayOutliersFinal(i,:)';
    IHA1 = pointArrayOutliersFinal(i,:)' - IHAextrapolationVector;
    IHA2 = pointArrayOutliersFinal(i,:)' + IHAextrapolationVector;
    IHAOutliersFinal = [IHA1 pointArrayOutliersFinal(i,:)' IHA2];
end

end