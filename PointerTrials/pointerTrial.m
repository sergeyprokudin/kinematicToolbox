function pointerTrial(pointerlength, path2c3dorStructData)
% pointerTrial()
%  Function for calculating a virtual point from a pointer. Inputs include
%  pointerLength (length of the pointer) and the path2c3dorStructData,
%  which can be a path string of a data strucutre according to
%  documentation. 

% Author: James Dunne, Massimo Satori, Cyril J Donnelly
% Created: Janurary 2010 | Updated: October 2014

if nargin == 0 
    % define the pointer length (mm)
    pointerlength = 355;
    % load the c3d
    [filein, pathname] = uigetfile({'*.c3d','C3D file'}, 'C3D data file...');
    structData = btk_loadc3d(fullfile(pathname,filein), 10);
elseif nargin == 1
    % load the c3d
    [filein, pathname] = uigetfile({'*.c3d','C3D file'}, 'C3D data file...');
    structData = btk_loadc3d(fullfile(pathname,filein), 10);
elseif nargin == 2
    if ~isstruct(path2c3dorStructData)
        structData = btk_loadc3d(path2c3dorStructData,10);
    end
else
    error('please figure out the correct inputs to this function')
end

%%
mkrStruct = structData.marker_data.Markers;
mkrNames    = fieldnames(mkrStruct);
nMkrs       = length(mkrNames); 

%%
% Get the end name of the pointer-end mkr
[pathstr,name,ext] = fileparts(structData.marker_data.Filename); 

% Determine the point name from the trial name
if isempty( strfind(name,'_') );
    pointName = name;
else
    pointName = name(strfind(name,'_')+1:end);
end
% if the marker is already in the struct, delete it. 
if ~isempty(strmatch(pointName, mkrNames))
    mkrStruct = rmfield(mkrStruct, mkrNames{strmatch(pointName, mkrNames)});
end

% Get the pointer markers out
ponterName  = 'PNTR';
x         = strmatch(ponterName, mkrNames);
pntrNames  = mkrNames(x);

%%  Push out the pointer markers
pntr1 = mkrStruct.(pntrNames{1});
pntr2 = mkrStruct.(pntrNames{2});
pntr3 = mkrStruct.(pntrNames{3});
pntr4 = mkrStruct.(pntrNames{4});


%% Get the segment markers
clusterMkrs    = fieldnames(mkrStruct);
minR  = min(x); 
maxR  = max(x);
clusterMkrs(minR:maxR) = [];

clust1 = mkrStruct.(clusterMkrs{1});
clust2 = mkrStruct.(clusterMkrs{2});
clust3 = mkrStruct.(clusterMkrs{3});



%% Determine virtual point position from Pointer markers
pointData   = zeros(length(pntr1),3);
meanPntr    = zeros(length(pntr1),3);

for i=1:length(pntr1)
    meanPntr(i,1:3)=mean([[pntr1(i,1) pntr2(i,1) pntr3(i,1) pntr4(i,1)]' [pntr1(i,2) pntr2(i,2) pntr3(i,2) pntr4(i,2)]' [pntr1(i,3) pntr2(i,3) pntr3(i,3) pntr4(i,3)]']);
    normal1=-cross(pntr1(i,1:3)-meanPntr(i,1:3),pntr2(i,1:3)-meanPntr(i,1:3));
    normal2=-cross(pntr4(i,1:3)-meanPntr(i,1:3),pntr1(i,1:3)-meanPntr(i,1:3));
    normal3=-cross(pntr3(i,1:3)-meanPntr(i,1:3),pntr4(i,1:3)-meanPntr(i,1:3));
    normal4=-cross(pntr3(i,1:3)-meanPntr(i,1:3),pntr2(i,1:3)-meanPntr(i,1:3));
    normalmean=[(normal1+normal2+normal3+normal4)/4];
    
    normalmean=-pointerlength*(normalmean/norm(normalmean));
    pointData(i,1:3)=meanPntr(i,1:3)+normalmean;    
end
     
%% Place condile marker in the coordinate system of the parent segment%
virtualMarker = MoveToTechnicalCS( [clust1 clust2 clust3] , pointData);

%% Export to .vmc file   
output_file = [pathstr '\' pointName '.vmc'];
% Open File    
fid = fopen(output_file,'w');
% write the names of the cluster markers and the virtual marker
fprintf(fid,'%s\t%s\t%s\t%s\t\n',char(clusterMkrs(1)),char(clusterMkrs(2)),char(clusterMkrs(3)),pointName);
% write the virtual marker location in the clustr technical system. 
fprintf(fid,'%f\t%f\t%f\n',virtualMarker) ;
%  Close fid
fclose(fid);


end