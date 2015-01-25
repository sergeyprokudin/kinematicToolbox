function stationData = sphericalFittingHelper(staticData,mkrData,parentMkrs,childMkrs,outputMkr);
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% functionVariables =  {[folderName '\RHJC1.c3d'] {'R_ASIS' 'L_ASIS' 'R_PSIS' 'L_PSIS'} {'R_TH1' 'R_TH2' 'R_TH2'} 'RHJC'}

%% Generate the local frame of the pelvis
if length(parentMkrs) == 4

    mkrData =  stationBuilder(mkrData, parentMkrs, {'midPelvis' 'SACR'} );
    [frameOrigin, frameOrient] = frameBuilder(mkrData,{'midPelvis'}, {parentMkrs{1:2} 'SACR'}, 'v1v3' );

    
elseif length(parentMkrs) == 3
    
     mkrData =  stationBuilder(mkrData, parentMkrs(1:2), {'midPelvis'} );
    [frameOrigin, frameOrient] = frameBuilder(mkrData,{'midPelvis'}, parentMkrs, 'v1v3' );

end

%% but the thigh stations into the local frame of the the Pelvis
newStations    = stationInFrame(mkrData, frameOrigin, frameOrient, childMkrs, 'local');

%% Using the local station points, calculate the center of
%  rotation
Cm = sphericalFitting(newStations);

%% Generate the local frame of the pelvis
if length(parentMkrs) == 4

     stationData =  stationBuilder(staticData, parentMkrs, {'midPelvis' 'SACR'} );
     [staticFrameOrigin, staticFrameOrient] = frameBuilder(stationData,{'midPelvis'}, {parentMkrs{1:2} 'SACR'}, 'v1v3' );

elseif length(parentMkrs) == 3

    stationData =  stationBuilder(staticData, parentMkrs(1:2), {'midPelvis'});
    [staticFrameOrigin, staticFrameOrient] = frameBuilder(stationData,{'midPelvis'}, parentMkrs, 'v1v3' );

end

% extend the center of rotation for the length (rows) of the data
CmG = repmat(Cm, length(staticFrameOrient),1);

% Calculate the location in the static trials global frame
staticStation   = stationInFrame(stationData,staticFrameOrigin, staticFrameOrient, {CmG}, 'global');

% add to the static's data structure for export. 
eval(['stationData.' char(outputMkr) ' = staticStation;' ])

end

