function appendXML2Static(hTrial,mkrStruct,trialName,dataPath,firstFrame,lastFrame,sampleRate,mkrFileInfo)

% build a list of all the mkrnames in the c3d. Will be used later as a
% lookup list. 
c3dMkrNames = [];
nc3dMkrs    = length(mkrStruct); 
for i = 1: nc3dMkrs;
        c3dMkrNames = [c3dMkrNames {mkrStruct(i).name}];
end

nbodies = length(mkrFileInfo.bodySet.bodies);

for i = 1: nbodies          % for each body

    
    bodyName = mkrFileInfo.bodySet.bodies(i).ATTRIBUTE.name;
    
    
    % get the list of all the parent and child markers associated with the
    % body. We will then use this information to either write mkr data
    % to the c3d file or save the local position of mkrs to the .xml file.
    
    [bodyName parentMkrNames childMkrnames d mkrFileTree] = mkrFileSearch(mkrFileInfo,bodyName);
    
    if  strcmpi(bodyName,'pelvis')    % if for the special case of the pelvis
        
        % If the pelvis then create the sacrum and generate the LTCS 
        % using the V1V3 transformation.
    
        % Order the pelvis in the structure
        parentStruct                = reoderstructure(mkrStruct, parentMkrNames );
        % Calculatre the position of the Sacrum using the 2 PSIS markers
        Sacr                        = (parentStruct(3).data + parentStruct(4).data)/2;
        % Add SACR to a copy of the fitered data. Just overwrite one of the
        % PSIS markers as they are not used in the analysis.
        parentStructCopy            = parentStruct;
        parentStructCopy(3).data    = Sacr;
        parentStructCopy(3).name    = 'SACR';
        parentMkrNames(3)          = {'SACR'};
        % Reoder the pelvis (parent) structure. Use this struture going forward
        parentMkrStruct  = reoderstructure(parentStructCopy, parentMkrNames(1:3) );
        
    else                                   % else for all other segment coordinate systems.
        
        % Reoder the parent structure. Use this struture going forward
        parentMkrStruct  = reoderstructure(mkrStruct, parentMkrNames );
        
        % A check to see if the parent names actually exist. If the
        % previous function returned an emoty matrix we want to skip the
        % rest of the for loop
        if isempty(parentMkrStruct)
           continue
        
        end
    end
    
    %  Using the parent markers (transofrmed into the local technical 
    %  coodinate system) go through each child marker and either save to
    %  c3d or to mkr file. This is done by comparing the string names in
    %  the c3d with the string in names in childMkrnames. It then looks up
    %  any data entries in the .xml file and moves data accordingly
    
    nChldMkrs = length(mkrFileInfo.bodySet.bodies(i).virtMarkerSet.virtMarker);
    
    for ii = 1: nChldMkrs               % for each child mkr
        
        % get the child marker name
        chldMkrName = mkrFileInfo.bodySet.bodies(i).virtMarkerSet.virtMarker(ii).name;
        
        
        % Run a for loop to see if the child mkr is in the c3d. Compare the
        % name to the list c3dMkrNames to find if its in C3D.
        for u = 1: nc3dMkrs
            if strcmpi(c3dMkrNames(u),chldMkrName) 
               % if it IS in the trial then  
                 mkrInTrial     = true;
                 break
            else 
               % else the child marker doesnt exist in the trial  
                 mkrInTrial     = false;
            end
        end
        
        % Depending if mkrInTrial is true or false, move the data from one
        % c3d to/from the .xml.
        % If mkr isnt in c3d, take the local coordinate & dump into the c3d
        if mkrInTrial == false 
               % get the marker data from the .xml file
               chldMkrData = mkrFileInfo.bodySet.bodies(i).virtMarkerSet.virtMarker(ii).locationInTech;

               % if chldMkrData from xml = [0 0 0]
               if chldMkrData(1) == 0 && chldMkrData(2) == 0 && chldMkrData(2) == 0
               
               else
                   % move the data to the c3d (special case pelvis uses V1V3
                   if strcmpi(bodyName,'pelvis')
                        save2C3D(hTrial,parentMkrStruct,chldMkrName,chldMkrData,firstFrame,lastFrame,1);
                   else
                        save2C3D(hTrial,parentMkrStruct,chldMkrName,chldMkrData,firstFrame,lastFrame);
                   end
                   
               end
        end
        
        
        % If mkr is in c3d, 
        if mkrInTrial == true
               % get the marker data from the .xml file
               chldMkrData = mkrFileInfo.bodySet.bodies(i).virtMarkerSet.virtMarker(ii).locationInTech;
        
               % if chldMkrData from xml = [0 0 0]
               if chldMkrData(1) == 0 && chldMkrData(2) == 0 && chldMkrData(2) == 0
               
                   % Transform c3d marker data into local coordinates
                  
                   if strcmpi(bodyName,'pelvis')  % (special case pelvis uses V1V3
                        [childMkrs] = coordinateSystemTransform('local', parentMkrStruct,mkrStruct(u).Data, 1);
                   else
                        [childMkrs] = coordinateSystemTransform('local', parentMkrStruct,mkrStruct(u).Data);
                   end 
                   
                   % Save child coordinate (in local frame) to the .xml
                   % file. 
                   childMkrs = mean(childMkrs);
                   [b p c d mkrFileInfo] = mkrFileSearch(mkrFileInfo,chldMkrName,childMkrs);
                   
               end
        end    
            
    end
    
    
     % Print the updated Marker .xml to subject foler. 
        wPref.StructItem = false; 
        xml_write(fullfile(dataPath, 'mkrFile.xml'), mkrFileInfo, 'MarkerSet',wPref); 
    
   
    
end   
    
end










































