function [meanUnitVectorOutliersRemovedFinal, pivotPointOutliersRemovedFinal, unitVectorArrayOutliersRemovedFinal, pointArrayOutliersRemovedFinal] = meanhelicalaxis_plots(parentCoords, childCoords, threshold, overlap, xAxisTerminal, yAxisOrigin, yAxisTerminal, orientationOutlierThreshold, positionOutlierThreshold, VideoRate)

close all
% function [meanUnitVector, pivotPoint, unitVectorArray, pointArray] = ...
%     meanhelicalaxis(parentCoords, childCoords, threshold, overlap,...
%     xAxisTerminal, yAxisOrigin, yAxisTerminal);
%
% MEANHELICALAXIS calculates instantaneous helical axes using the technique
% described by Stokdijk et al. (1999). ClinBiomech, 14 , 177-84.
% PARENTCOORDS and CHILDCOORDS are 2-D arrays built columnwise with the x,
% y, z coordinates of markers attached to the parent and child segments
% respectively. The rows of PARENTCOORDS and CHILDCOORDS represent time.
% THRESHOLD is a scalar that defines the minimum rotation over which the
% instantaneous helical axes are defined as valid. XAXISTERMINAL is a
% scalar that defines which parent marker is used to define the terminal
% point of the x-axis of the parent segment's technical reference frame.
% YAXISORIGIN and YAXISTERMINAL are scalars that define which parent
% markers are used to define the origin and termination of a vector
% parallel with the yaxis of the parent segments technical reference frame.
% OVERLAP is a string constant ('y' or 'n') that defines whether or not
% instantaneous helical axes are calculated from overlapping sections of
% the time history. Outlying IHAs can be removed using by specifying
% the scalar thresholds ORIENTATIONOUTLIERTHRESHOLD and 
% POSITIONOUTLIERTHRESHOLD. These thresholds correspond to the maximum
% allowable Pythagorean difference (in standard deviations) of the 
% orientation and position (of % the z = 0 intersect) of the IHAs from the 
% MHA. Once outliers have been removed, the MHA is recalculated.

%
% MEANHELICALAXIS calls the following custom functions: screw, soder &
% segmentorientation2

% Version 1 by:        Thor Besier
% Current version by:  Peter Mills (pmills@cyllene.uwa.edu.au)
% Last modified:       3 September, 2004

%   Check input arguments
if nargin < 7
    error('The first seven input arguements are required');
elseif nargin == 7
    positionOutlierThreshold = 9999;
    positionOutlierThreshold = 9999;
elseif nargin == 8
    positionOutlierThreshold = 9999;
end
    
[nRows, nCols] = size(parentCoords);
nMarkers = nCols/3;

%%  Seperate individual markers from input arrays and define parent origin
sumParentMarkers = zeros(nRows, 3);
markerIndex = 1;
for i = 1:3:nCols - 2;
    eval(['parentMarker' num2str(markerIndex) ' = parentCoords(:,i:i+2);'])
    eval(['childMarker' num2str(markerIndex) ' = childCoords(:,i:i+2);'])
    sumParentMarkers = sumParentMarkers + parentCoords(:,i:i+2);
    markerIndex = markerIndex + 1;
end
originParent = sumParentMarkers/nMarkers;


%%  Define the thigh origin and yaxis, which lies parallel to the line
%   bisecting yAxisOrigin and yAxisTerminal from parentCoords
yAxisLine = eval(['(parentMarker' num2str(yAxisOrigin)...
    ' - parentMarker' num2str(yAxisTerminal) ') + originParent']);


%% Calculate unit vectors of parent reference frame relative to global
[e1, e2, e3] = ...
    eval(['segmentorientation2(originParent - yAxisLine, parentMarker' ...
    num2str(xAxisTerminal) ' - originParent)']);


%% Transform parent and child marker coordinates from global to parent
% coordinate system
for i=1:nRows
    rotMat = [e1(i,:); e2(i,:); e3(i,:)];
    originParentVector = originParent(i,:)';
    for j = 1:nMarkers;
        eval(['parentMarker' num2str(j)...
            '_PCS(i,:) = (rotMat * (parentMarker' num2str(j)...
            '(i,:)'') - rotMat * originParentVector)'';'])
        eval(['childMarker' num2str(j)...
            '_PCS(i,:) = (rotMat * (childMarker' num2str(j)...
            '(i,:)'') - rotMat * originParentVector)'';'])
    end
end


% OPTIONAL: Plot parent and child coords in PCS                     [START]
dataOK = menu('View plotted data?', 'Yes', 'No');
if dataOK == 1;
figure(1)
hold on
h1(1) = plot3(parentMarker1_PCS(1,1), parentMarker1_PCS(1,2),...
    parentMarker1_PCS(1,3), 'ko', 'MarkerFaceColor', 'k');
plot3(parentMarker2_PCS(1,1), parentMarker2_PCS(1,2),...
    parentMarker2_PCS(1,3), 'ko', 'MarkerFaceColor', 'k')
plot3(parentMarker3_PCS(1,1), parentMarker3_PCS(1,2),...
    parentMarker3_PCS(1,3), 'ko', 'MarkerFaceColor', 'k')
h1(2) = plot3(childMarker1_PCS(1,1), childMarker1_PCS(1,2),...
    childMarker1_PCS(1,3), 'ro','MarkerFaceColor', 'r');
plot3(childMarker2_PCS(1,1), childMarker2_PCS(1,2),...
    childMarker2_PCS(1,3), 'ro', 'MarkerFaceColor', 'r')
plot3(childMarker3_PCS(1,1), childMarker3_PCS(1,2),...
    childMarker3_PCS(1,3), 'ro','MarkerFaceColor', 'r')
xlabel('X')
ylabel('Y')
zlabel('Z')
title('Parent and child coordinates in parent coordinate system')
axis equal
grid on
end
% OPTIONAL: Plot parent and child coords in PCS                       [END]

%%   Preallocate and define arrays and constants
unitVectorArray = [];
pointArray = [];
nIHAs = 0;
intersect = 1;  %   Location of the screw axis where it intersects
% either the x=0 (intersect=1), the y=0 (intersect=2), or the z=0
% (intersect=3) plane.


%%  Calculate IHAs using userdefined rotation threshold and logical loop to
%   perform IHA calculations with or without overlapping segments
try
    switch VideoRate
        case 50
            increment = 1;
        case 100
            increment = 1;
        case 250
            increment = 4;
        case 400
            increment = 4;
    end
catch
    increment = 1;
end
currentIndex = increment; % Initialise currentindex        
i = 1;
while i + currentIndex <= nRows
    childMarkerInput = [];
    for j = 1:nMarkers;
        childMarkerInput = eval(['[childMarkerInput, [childMarker' ...
            num2str(j) '_PCS(i,:); childMarker' num2str(j)...
            '_PCS(i + currentIndex,:)]]']);
    end
    %   Calculate transformation matrix for child segment using svd
    [T, res] = soder(childMarkerInput);
    [unitVector, point, phi, t] = screw(T, intersect);
    
    %   Ensure all unit vectors have positive z components to simplify
    %   calculation of mean unit vector
    if unitVector(3) < 0
        unitVector = -unitVector;
    end
    
    % Only use helical axes that are predicted with phi greater than
    % predefined 'threshold' degrees
    if abs(phi) < threshold
        currentIndex = currentIndex + increment;
    else
        % Append to IHA unit vector and point arrays
        unitVectorArray = [unitVectorArray; unitVector'];
        pointArray = [pointArray; point'];

        if overlap == 'y'
            i = i + increment;
        else
            i = i + currentIndex;
        end
        currentIndex = increment;
        nIHAs = nIHAs + 1;
    end
end


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
    end
end

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
    pivotPointOutliersRemoved1stPass = inv(qMean) * qPointMean;
    return
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
    end
end

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
qSum= zeros(3,3);
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

%% Plot mean helical axis to check validity
if dataOK == 1;
figure(1)
h1(3) = plot3(MHAOutliersRemovedFinal(1,:), MHAOutliersRemovedFinal(2,:),...
    MHAOutliersRemovedFinal(3,:), 'b', 'LineWidth', 2);

legend(h1, 'Parent Markers', 'Child Markers', 'Mean helical axis',...
    'Location', 'SouthOutside');

dataOK1 = menu('Is this data OK??', 'Yes', 'No');
if dataOK1 == 2;
    error('Optimisation aborted by user');
end
end
