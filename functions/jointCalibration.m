function [mkrFileTree] = jointCalibration(mkrStruct,dataPath,bodyNames,mkrFileTree,pointer, functional)
%% kneeCalibration() calibrates the functional axis to the anatomical FC's
% The projections are done by computing the lateral and medial planes of the joint based on
%	the location of the laterally and medially placed markers.  The intersection of this plane
%	and the actual computed joint axis then determines the new and actual medial marker/lateral marker.
%	The center of the joint is equivalent to the center of these new points, and thus lies
%	on the actual computed joint axis.
%
%



if ischar(bodyNames)
else    
    if length(bodyNames)>1
       error('more than 1 body has been input for analysis. bodyNames > 1 ')
    else
        bodyNames = char(bodyNames);
    end
end


%% Find the marker label names of each body and store in a structure
    % get the parent and child mkr names
    [bodyMkrs mkrFileTree] = mkrFileSearch(mkrFileTree,bodyNames);
    % store in parent and child mkr names in a structure to look up later
    jointNameStruct = struct('parentMkrs',{bodyMkrs.expMkrs},'childMkrs',{bodyMkrs.virMkrs});
     % the number of bodies to run analysis
    nBodies    = length(jointNameStruct);
    % reorder the parent structure
    parentStruct = reorderStruct(mkrStruct, bodyMkrs.expMkrs ); 
    
    
%% For each body find the axis markers    
        % If a fourth variable has been input, it will be the string identifier
        % for the femoral condyle pointer trials. 
        if pointer == true
            mkrIndex = 1;
            % For the all the child markers
            for u = 1:length(jointNameStruct.childMkrs)
            % What is the name of the child markers
                 mkrName = char(lower(jointNameStruct.childMkrs(u)));
            % Does the child marker name have the pointer string in it    
                if ~isempty(strfind(mkrName,'pointer')) 
            % If it does, find the childMkr data in mkrStruct and dump out 
                   eval(['FC' num2str(mkrIndex) '=  dataInStruct(mkrStruct, char(jointNameStruct.childMkrs(u)));'])
                   eval(['FC' num2str(mkrIndex) 'Name=  jointNameStruct.childMkrs(u);'])
                   mkrIndex = mkrIndex + 1;
                elseif isempty(strfind(mkrName,'fun')) && ~isempty(strfind(mkrName,'jc'))
                    JCname = jointNameStruct.childMkrs(u);
                end
            end
            
            % calculate the joint center = 
            JC = (FC1+FC2)/2;
            % saving the pointer data as an anatomical data.
            tpName1 = strrep(char(FC1Name),'pointer','');
            tpName2 = strrep(char(FC2Name),'pointer','');
            % turn to local 
            [JC]       = coordinateSystemTransform('local',parentStruct, JC)  ;
            [FC1local] = coordinateSystemTransform('local',parentStruct, FC1) ;
            [FC2local] = coordinateSystemTransform('local',parentStruct, FC2) ;
            
            % Save points data to the mkrFileTree structure
                 [bodyMkrs mkrFileTree]...
                           = mkrFileSearch(mkrFileTree, tpName1 ,mean(FC1local));
                 [bodyMkrs mkrFileTree]...
                           = mkrFileSearch(mkrFileTree, tpName2 ,mean(FC2local));
                 [bodyMkrs mkrFileTree]...
                           = mkrFileSearch(mkrFileTree, JCname  ,mean(JC));      
                       
            % Else the femoral condyle marker is an anatomical one and would be
            % named either 'LLFC' or 'LLFCanatomical'. Either way, it would
            % contain the strings 'fc' and NOT the strings 'pointer or
            % 'functional'. 
        else 
            mkrIndex = 1;
            % For the all the child markers
            for u = 1:length(jointNameStruct.childMkrs)
            % What is the name of the child markers
                 mkrName = char(lower(jointNameStruct.childMkrs(u)));
            % Does the child marker name NOT have JC, pointer or functional 
            % in the the string 
                if isempty(strfind(mkrName,'jc')) && isempty(strfind(mkrName,'pointer')) && isempty(strfind(mkrName,'fun'))
            % If it does, find the childMkr data in mkrStruct and dump out        
                   eval(['FC' num2str(mkrIndex) '=  dataInStruct(mkrStruct, char(jointNameStruct.childMkrs(u)));'])
                   eval(['FC' num2str(mkrIndex) 'Name=  jointNameStruct.childMkrs(u);'])
                   mkrIndex = mkrIndex + 1;
                elseif isempty(strfind(mkrName,'fun')) && ~isempty(strfind(mkrName,'jc'))
                    JCname = jointNameStruct.childMkrs(u);
                end
             end       
                % calculate the joint center = 
                JC = (FC1+FC2)/2;
                % turn to local 
                [JC]       = coordinateSystemTransform('local',parentStruct, JC)  ;
                % Save points data to the mkrFileTree structure
                [b p v data mkrFileTree]...
                           = mkrFileSearch(mkrFileTree, JCname   ,mean(JC));     
                
            
        end

        
%% Find the functional axis mkrs

if functional == true
            HAJCName = [];
            mkrIndex = 1;
            % For the all the child markers
            for u = 1:length(jointNameStruct.childMkrs)
            % What is the name of the child markers
                 mkrName = char(lower(jointNameStruct.childMkrs(u)));
            % Is functional & not joint center?  
                if ~isempty(strfind(mkrName,'fun')) && isempty(strfind(mkrName,'jc'))
                    % If it does, find the childMkr data in mkrStruct and dump out 
                   eval(['HA' num2str(mkrIndex) '=  dataInStruct(mkrStruct, char(jointNameStruct.childMkrs(u)));'])
                   eval(['HA' num2str(mkrIndex) 'Name=  jointNameStruct.childMkrs(u);'])
                   mkrIndex = mkrIndex + 1;
            % Is functional & joint center?        
                elseif ~isempty(strfind(mkrName,'fun')) && ~isempty(strfind(mkrName,'jc'))
                   HAJCName =  jointNameStruct.childMkrs(u);
                end
            end
            
            if isempty (HAJCName)
               error(['Joint center name for functional joint has not been defined'])
            end
            
%% Create the new functional axis mkrs based on the position of the FC mkrs

        % Define epicondylar axis
            epicondylar_axis = (FC1-FC2);
        % Define starting joint centre position
            joint_centre = (FC1+FC2)/2;
        % Define helical axes vectors
            helical_axis_vector = HA1-HA2;            
                        
       for u=1:length(FC1)
                % Projects the joint center of the manually placed markers to the equivalent
                %	joint center on the computed actual joint axis
                t = (dot(epicondylar_axis(u,:),joint_centre(u,:))-dot(epicondylar_axis(u,:),HA1(u,:)))/dot(epicondylar_axis(u,:),helical_axis_vector(u,:));
                new_x = HA1(u,1)+helical_axis_vector(u,1)*t;
                new_y = HA1(u,2)+helical_axis_vector(u,2)*t;
                new_z = HA1(u,3)+helical_axis_vector(u,3)*t;
                newJC(u,:)=[new_x;new_y;new_z];

                % Projects the manually placed lateral marker to the computed actual joint axis
                t = (dot(epicondylar_axis(u,:),FC1(u,:))-dot(epicondylar_axis(u,:),HA1(u,:)))/dot(epicondylar_axis(u,:),helical_axis_vector(u,:));
                new_x = HA1(u,1)+helical_axis_vector(u,1)*t;
                new_y = HA1(u,2)+helical_axis_vector(u,2)*t;
                new_z = HA1(u,3)+helical_axis_vector(u,3)*t;
                newFC1(u,:)=[new_x;new_y;new_z];

                % Projects the manually placed medial marker to the computed actual joint axis
                t = (dot(epicondylar_axis(u,:),FC2(u,:))-dot(epicondylar_axis(u,:),HA1(u,:)))/dot(epicondylar_axis(u,:),helical_axis_vector(u,:));
                new_x = HA1(u,1)+helical_axis_vector(u,1)*t;
                new_y = HA1(u,2)+helical_axis_vector(u,2)*t;
                new_z = HA1(u,3)+helical_axis_vector(u,3)*t;
                newFC2(u,:)=[new_x;new_y;new_z];
        end
        
        
%% Put all the coordinates in the local TCS of the paretn markers
       [newJClocal]  = coordinateSystemTransform('local',parentStruct, newJC)  ;
       [newFC1local] = coordinateSystemTransform('local',parentStruct, newFC1) ;
       [newFC2local] = coordinateSystemTransform('local',parentStruct, newFC2) ;
                                    
       newJClocal   = mean(newJClocal);
       newFC1local  = mean(newFC1local);
       newFC2local  = mean(newFC2local);
                                    
%% Save the local coordinates to the marker file 

    % Save points data to the mkrFileTree structure
            [bodyMkrs mkrFileTree]...
                       = mkrFileSearch(mkrFileTree, HAJCName,newJClocal);
            [bodyMkrs mkrFileTree]...
                       = mkrFileSearch(mkrFileTree, HA1Name, newFC1local);
            [bodyMkrs mkrFileTree]...
                       = mkrFileSearch(mkrFileTree, HA2Name, newFC2local); 

   

end
 % Print the updated Marker .xml to subject foler. 
        wPref.StructItem = false; 
        xml_write(fullfile(dataPath, 'mkrFile.xml'), mkrFileTree, 'MarkerSet',wPref);   




end











