

%% script for converting all the c3d's to opensim format

workingFolder = cd;

folderName = uigetdir(workingFolder,'select C3D folder');

cd(folderName)

c3dFiles = dir('*.c3d');

% Process the c3d's

for i = 1:length(c3dFiles)

    c3d2Opensim('c3dFilePath',[folderName '\' c3dFiles(i).name], ...
             'rotation', {'x' 90}, ...
             'filter', {'mrks' 'critt' 16 'grf' 'critt' 40});
            

end

staticData = jointCenterCalculation(...
    'rotate',     {'x' 90 },...
    'static',     {[folderName '\staticunloaded1.c3d']},...
    'sphericalFit',   {[folderName '\RHJC1.c3d'] {'R_ASIS' 'L_ASIS' 'R_PSIS' 'L_PSIS'} {'R_TH1' 'R_TH2' 'R_TH2'} 'RHJC'}, ...
    'sphericalFit',   {[folderName '\LHJC1.c3d'] {'R_ASIS' 'L_ASIS' 'R_PSIS' 'L_PSIS'} {'L_TH3' 'L_TH2' 'L_TH2'} 'LHJC'},...
    'anatomicalJoint', {[folderName '\staticunloaded1.c3d'],  {'R_Knee' 'R_MKnee'}, {'RKJC'} }, ...
    'anatomicalJoint', {[folderName '\staticunloaded1.c3d'],  {'L_Knee' 'L_MKnee'}, {'LKJC'} }, ...
    'anatomicalJoint', {[folderName '\staticunloaded1.c3d'], {'R_Ankle' 'R_MAnkle'}, {'RAJC'} }, ...
    'anatomicalJoint', {[folderName '\staticunloaded1.c3d'], {'L_Ankle' 'L_MAnkle'}, {'LAJC'} } );


%% Calculate the Joint angles from the anatomical marker based frames and 
% virtual markers
%  staticData = jointPose(...
%     'pelvis',{ {'midPelvis'} {'R_ASIS' 'midPelvis' 'SACR'} {'v1v3'} },...
%     'rightFemur', { {'RKJC'} {'R_Knee' 'RKJC' 'RHJC'} {'v1v2'} },... 
%     'rightTibia', { {'RAJC'} {'R_Ankle' 'RAJC' 'RKJC'} {'v1v2'} },...
%     'rightFoot',  { {'RAJC'} {'R_Ankle' 'RAJC' 'RKJC'} {'v1v2'} },...
%     'jointAngle', { {'pelvis' 'rightFemur' 'rHipAngle'},...
%                     {'rightFemur' 'rightTibia' 'rKneeAngle'},...
%                     {'rightTibia' 'rightKnee' 'rAnkleAngle'} });




















