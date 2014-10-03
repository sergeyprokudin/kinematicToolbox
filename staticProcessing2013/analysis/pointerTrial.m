function [pointInLTCS localTCSMarkers] = pointerTrial(mkrStruct,trialName,dataPath,pointerBodyName,mkrFileInfo) ;
%% pointerTrial calculation of a axis point using a pointer device
%    pointerTrial() calculates a point in space based on the perpendicular
%    projection from a four corner plane. This script is designed to run 
%    through Vicon Pecs Pipeline.The plane is assumed to be
%    labelled clockwise ('PNTR1' 'PNTR2' 'PNTR3' 'PNTR4') and is held
%    relative to cluster of markers determined by the trial name.
%
%    Naming of the point is based off the name of the trial
%    trialName     = 'LLFCpointer'
%    trialName     = 'RMFCpointer'
%     
%    Output is a virtual marker coordinate file (.vmc) that can be imported
%    at alater time for use in static or dynamic processing
%
% Authors:J. Dunne (James.dunne@stanford.edu), M. Satori Created: 01.14.10
% Upd: 11.15.12
 
    
%% Define the necessary variables/labels
%Negative(-355) was used because markers were labelled clockwise...
%If markers that define plane are labelled anticlockwise, use +355. 
   pointerlength=-355;

%% Find the parent markers (Markers that define your local technical
%  coordinate system. 

%  The defined point has to be visible in your subject
%  mkfFile and trialName must be the a matching string ie 'LLFCpointer'
   pointName = trialName;
   
% Access the names of the markers that define the plane on the pointer body   
    [b pointerBodyNames v d c]...
               = mkrFileSearch(mkrFileInfo, pointerBodyName);
   
% Access the names of the parent markers for this point given the trialname   
    [b expParentMkrNames v d c]...
               = mkrFileSearch(mkrFileInfo,pointName);
   
   
%%	Reorder and dump pointer mkrs out into variables for calculation
% Reoder the Mkr structure so the correct data can be accessed    
    [pointerMkrstruct] = reorderStruct(mkrStruct,pointerBodyNames);

%  Create individual arrays for the pointer markers from the marker strucutre
    [PNTR1] = accessStructData(pointerMkrstruct,  pointerBodyNames(1));   
    [PNTR2] = accessStructData(pointerMkrstruct,  pointerBodyNames(2));
    [PNTR3] = accessStructData(pointerMkrstruct,  pointerBodyNames(3));   
    [PNTR4] = accessStructData(pointerMkrstruct,  pointerBodyNames(4));
    
%% Determine condyle position from parentMkrs
PNTRLength=length(PNTR1);
point=zeros(PNTRLength,3);
meanPNTR=zeros(PNTRLength,3);
for i=1:PNTRLength(1)
    meanPNTR(i,1:3)=mean([[PNTR1(i,1) PNTR2(i,1) PNTR3(i,1) PNTR4(i,1)]' [PNTR1(i,2) PNTR2(i,2) PNTR3(i,2) PNTR4(i,2)]' [PNTR1(i,3) PNTR2(i,3) PNTR3(i,3) PNTR4(i,3)]']);
    normal1=-cross(PNTR1(i,1:3)-meanPNTR(i,1:3),PNTR2(i,1:3)-meanPNTR(i,1:3));
    normal2=-cross(PNTR4(i,1:3)-meanPNTR(i,1:3),PNTR1(i,1:3)-meanPNTR(i,1:3));
    normal3=-cross(PNTR3(i,1:3)-meanPNTR(i,1:3),PNTR4(i,1:3)-meanPNTR(i,1:3));
    normal4=-cross(PNTR3(i,1:3)-meanPNTR(i,1:3),PNTR2(i,1:3)-meanPNTR(i,1:3));
    normalmean=[(normal1+normal2+normal3+normal4)/4];
    
    normalmean=pointerlength*(normalmean/norm(normalmean));
    pointData(i,1:3)=meanPNTR(i,1:3)+normalmean;    
end


%% Transform global point into local coordinates

% Re- order the mkrStruct so the parent markers populate the first three
% cases
localTCSMarkers = reorderStruct(mkrStruct,expParentMkrNames);

[transformedChildMkrArray]...
    = coordinateSystemTransform('local', localTCSMarkers, pointData);

%% Store the local  coordinates of this point back to the MkrFile

% get the mean position of the point (in the local TCS)
pointInLTCS = mean(transformedChildMkrArray);


% Access the names of the parent markers for this point given the trialname   
    [b expParentMkrNames v data mkrFileInfo]...
               = mkrFileSearch(mkrFileInfo, pointName, pointInLTCS);

%% Print the updated Marker .xml to subject foler. 
wPref.StructItem = false; 
xml_write(fullfile(dataPath, 'mkrFile.xml'), mkrFileInfo, 'MarkerSet',wPref);

end
























