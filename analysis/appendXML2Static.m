function appendXML2Static(hTrial,mkrStruct,trialName,dataPath,firstFrame,lastFrame,sampleRate,mkrFileTree)

% build a list of all the mkrnames in the c3d. Will be used later as a
% lookup list. 
c3dMkrNames = [];
nc3dMkrs    = length(mkrStruct); 
for i = 1: nc3dMkrs;
        c3dMkrNames = [c3dMkrNames {mkrStruct(i).name}];
end

nbodies = length(mkrFileTree.bodySet.bodies);

for i = 1: nbodies          % for each body

    
    bodyName = mkrFileTree.bodySet.bodies(i).ATTRIBUTE.name;
    
    
    % get the list of all the parent and child markers associated with the
    % body. We will then use this information to either write mkr data
    % to the c3d file or save the local position of mkrs to the .xml file.
    
    [bodyMkrs mkrFileTree] = mkrFileSearch(mkrFileTree,bodyName);
    
    if  strcmpi(bodyName,'pelvis')    % if for the special case of the pelvis
        % If the pelvis then create the sacrum and generate the LTCS 
        % using the V1V3 transformation.
        [parentMkrStruct] = pelvisOrder(mkrStruct,bodyMkrs.expMkrs);
        
    else                                   % else for all other segment coordinate systems.
        
        % Reoder the parent structure. Use this struture going forward
        parentMkrStruct  = reorderStruct(mkrStruct, bodyMkrs.expMkrs );
        
        % A check to see if the parent names actually exist. If the
        % previous function returned an emoty matrix we want to skip the
        % rest of the for loop
        if isempty(parentMkrStruct)
           continue
        
        end
    end
    
    %  Using the parent markers (transformed into the local technical 
    %  coodinate system) go through each child marker and either save to
    %  c3d or to mkr file. This is done by comparing the string names in
    %  the c3d with the string in names in childMkrnames. It then looks up
    %  any data entries in the .xml file and moves data accordingly
    
    if ~isempty(bodyMkrs.virMkrs)
        nChldMkrs = length(bodyMkrs.virMkrs);

        for ii = 1: nChldMkrs               % for each child mkr
            % get the child marker name
            chldMkrName = char(bodyMkrs.virMkrs(ii));
            % run through the virtual mkrs
            [chldMkrData] = searchVirtMkrs(hTrial,parentMkrStruct,mkrStruct,mkrFileTree,chldMkrName,c3dMkrNames,firstFrame,lastFrame,ii);  
        end
    end
end
    
% Print the updated Marker .xml to subject foler. 
wPref.StructItem = false; 
xml_write(fullfile(dataPath, 'mkrFile.xml'), mkrFileTree, 'MarkerSet',wPref); 
    
   
    
end   
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chldMkrData] = searchVirtMkrs(hTrial,parentMkrStruct,mkrStruct,mkrFileTree,chldMkrName,c3dMkrNames,firstFrame,lastFrame,ii)

            % get the marker data from the .xml file
            [chldMkrData mkrFileTree] = mkrFileSearch(mkrFileTree,chldMkrName);
            nc3dMkrs = length(c3dMkrNames);
            % Run a for loop to see if the child mkr is in the c3d. Compare the
            % name to the list c3dMkrNames to find if its in C3D.
            for u = 1: nc3dMkrs
                if strcmpi(c3dMkrNames(u),chldMkrName) 
                   % if it IS in the trial then  
                    if chldMkrData.data(1) == 0 && chldMkrData.data(2) == 0 && chldMkrData.data(2) == 0
                     
                       if strcmpi(chldMkrData.bodyName,'pelvis')  % (special case pelvis uses V1V3
                            [childMkrs] = coordinateSystemTransform('local', parentMkrStruct,mkrStruct(u).data, 1);
                       else
                            [childMkrs] = coordinateSystemTransform('local', parentMkrStruct,mkrStruct(u).data);
                       end 

                       % Save child coordinate (in local frame) to the .xml
                       % file. 
                       childMkrs = mean(childMkrs);
                       [chldMkrData mkrFileTree] = mkrFileSearch(mkrFileTree,chldMkrName,childMkrs);
                     else
                         
                        if strcmpi(chldMkrData.bodyName,'pelvis')
                            save2C3D(hTrial,parentMkrStruct,chldMkrName,chldMkrData.data,firstFrame,lastFrame,1);
                        else
                            save2C3D(hTrial,parentMkrStruct,chldMkrName,chldMkrData.data,firstFrame,lastFrame);
                        end 
                     
                    end
                    return 
                end
            end
            
            
            % else the child marker doesnt exist in the trial         
           if strcmpi(chldMkrData.bodyName,'pelvis')
                save2C3D(hTrial,parentMkrStruct,chldMkrName,chldMkrData.data,firstFrame,lastFrame,1);
           else
                save2C3D(hTrial,parentMkrStruct,chldMkrName,chldMkrData.data,firstFrame,lastFrame);
           end
           
            
end





















