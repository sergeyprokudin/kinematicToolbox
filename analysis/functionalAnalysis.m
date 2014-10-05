function  [pointData pointName parentMarkerData] = functionalAnalysis(mkrStruct,trialName,dataPath,firstFrame,lastFrame,sampleRate,bodyNames,mkrFileInfo); 
%% functionalAnalysis for Ball Joint and Helical Axis calculation 
%   functionalAnalysis() runs analysis center of rotation analysis on 
%   Type of analysis is determined by string in trial name
%   'FunHip','FunKnee'
%   
%   Author:  James Dunne (dunne.jimmy@gmail.com)
%            Thor Besier
%            Cyril J Donnelly
%   Created: Janurary 2010
%   Updated: Novememer 2013

%
% Access the names of the markers attached to a body   

%% Create some empty array's to fill later
pointName =[];
pointData =[];
parentMarkerData =[];

%% Filter marker Data (butterworth)
filtMkrStruct = filterData(8,4,sampleRate,mkrStruct);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hip Joint center calculation 
if ~isempty(strfind(lower(trialName),'hip'));
    
     % Define the marker names. These have to remain constant throughout
        % pelvis markers
            [b pelvisNameArray v d c]            = mkrFileSearch(mkrFileInfo,char(bodyNames(1)));
        % left thigh markers
            [b leftThighNameArray v d c]         = mkrFileSearch(mkrFileInfo,char(bodyNames(2)));
        % Right thigh markers
            [b rightThighNameArray v d c]        = mkrFileSearch(mkrFileInfo,char(bodyNames(4)));
           

        % Order the pelvis in the structure
            pelvisStruct                = reorderStruct(filtMkrStruct, pelvisNameArray );
        % Calculatre the position of the Sacrum using the 2 PSIS markers
            Sacr                        = (pelvisStruct(3).data + pelvisStruct(4).data)/2;
        % Add SACR to a copy of the fitered data. Just overwrite one of the
        % PSIS markers as they are not used in the analysis.
            pelvisStructCopy            = pelvisStruct;
            pelvisStructCopy(3).data    = Sacr;
            pelvisStructCopy(3).name    = 'SACR';
            pelvisNameArray(3)          = {'SACR'};
        % Reoder the pelvis (parent) structure
            parentMkrStruct  = reorderStruct(pelvisStructCopy, pelvisNameArray(1:3));
            parentMarkerData = parentMkrStruct(1:3);
            
        % Now that we have a parent structure with the correct order, we 
        % can check for the side (tagged in the trialName), put the child
        % markers in the parent coordinate frame, and run the analysis. 
            
             % in the case of the trialname containing an 'l' (left side trial) 
             % or the trial having neither an 'r' or an 'l' (both side tial)
         if   ~isempty(strfind(lower(trialName),'l')) || isempty(strfind(lower(trialName),'r'))
             
             % Send the child names and parent structure to the a sorter
             % that then passes it to the hip functional code (below)
             LHJC = hipJointCenter(pelvisStructCopy,leftThighNameArray);
             pointName = [pointName {'LHJCfunctional'}];
             pointData = [pointData;LHJC'];
             
            %  Update the subject marker file and print to file 
            %    Access the names of the parent markers for this point given the trialname   
            [b expParentMkrNames v data mkrFileInfo]...
                       = mkrFileSearch(mkrFileInfo, 'LHJCfunctional', LHJC);
         end
         
         
             % in the case of the trialname containing an 'r' (right side trial)
             % or the trial having neither an 'r' or an 'l' (both side
             % tial)
        if   ~isempty(strfind(lower(trialName),'r')) || isempty(strfind(lower(trialName),'l'))
             
             % Send the child names and parent structure to the a sorter
             % that then passes it to the hip functional code (below)
             RHJC = hipJointCenter(pelvisStructCopy,rightThighNameArray);
             pointName = [pointName {'RHJCfunctional'}];
             pointData = [pointData;RHJC'];
             
             
             % Access the names of the parent markers for this point given the trialname   
             [b expParentMkrNames v data mkrFileInfo]...
                       = mkrFileSearch(mkrFileInfo, 'RHJCfunctional', RHJC);
        end
         
         % Print the updated Marker .xml to subject foler. 
            wPref.StructItem = false; 
            xml_write(fullfile(dataPath, 'mkrFile.xml'), mkrFileInfo, 'MarkerSet',wPref);
end

%% Knee Joint axis (helical axis)
if ~isempty(strfind(lower(trialName),'knee'));
    
    
    % Define the marker names. These have to remain constant throughout
        % left thigh markers
        [b leftThighNameArray v d c]    = mkrFileSearch(mkrFileInfo,char(bodyNames(2)));
        % left Tibia markers
        [b leftTibiaNameArray v d c]    = mkrFileSearch(mkrFileInfo,char(bodyNames(3)));
        % Right thigh markers
        [b rightThighNameArray v d c]   = mkrFileSearch(mkrFileInfo,char(bodyNames(4)));
        % Right Tibia markers
        [b rightTibiaNameArray v d c]   = mkrFileSearch(mkrFileInfo,char(bodyNames(5)));
    
    
    
    
             % in the case of the trialname containing an 'l' (left side trial) 
             % or the trial having neither an 'r' or an 'l' (both side
             % tial)
             if   ~isempty(strfind(lower(trialName),'l')) || isempty(strfind(lower(trialName),'r'))    
                    
                   [LLFC LMFC lFemurMkrsInLocal ltibiaMkrsInLocal] = helicalAxisCalc(filtMkrStruct,leftThighNameArray,leftTibiaNameArray,sampleRate);
     
                    pointName = [pointName {'LLFCfunctional'}];
                    pointName = [pointName {'LMFCfunctional'}];
                    pointData = [pointData;LLFC'];
                    pointData = [pointData;LMFC'];
                    
                  % Save points data to the mkrFileInfo structure
                    [b expParentMkrNames v data mkrFileInfo]...
                                   = mkrFileSearch(mkrFileInfo, 'LLFCfunctional', LLFC);
                    [b expParentMkrNames v data mkrFileInfo]...
                                   = mkrFileSearch(mkrFileInfo, 'LMFCfunctional', LMFC);   
                               
                               
                    parentMarkerData = [parentMarkerData;lFemurMkrsInLocal(1:3)]  ;         

             end    
    
    
             % in the case of the trialname containing an 'r' (right side trial)
             % or the trial having neither an 'r' or an 'l' (both side
             % tial)
        if   ~isempty(strfind(lower(trialName),'r')) || isempty(strfind(lower(trialName),'l'))
    
            [RMFC RLFC rFemurMkrStruct rtibiaMkrStruct] = helicalAxisCalc(filtMkrStruct,rightThighNameArray,rightTibiaNameArray,sampleRate);
              
                    pointName = [pointName {'RLFCfunctional'}];
                    pointName = [pointName {'RMFCfunctional'}];
                    pointData = [pointData;RLFC'];
                    pointData = [pointData;RMFC'];
                    
            % Save points data to the mkrFileInfo structure
            [b expParentMkrNames v data mkrFileInfo]...
                       = mkrFileSearch(mkrFileInfo, 'RLFCfunctional', RMFC);
            [b expParentMkrNames v data mkrFileInfo]...
                       = mkrFileSearch(mkrFileInfo, 'RMFCfunctional', RLFC); 
            
            parentMarkerData = [parentMarkerData;rFemurMkrStruct(1:3)];
        end

    % Print the updated Marker .xml to subject foler. 
        wPref.StructItem = false; 
        xml_write(fullfile(dataPath, 'mkrFile.xml'), mkrFileInfo, 'MarkerSet',wPref);   
        
        
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [HA1 HA2 parentMkrStruct childMkrStruct] = helicalAxisCalc(MkrStruct,parentMkrStrings,childMkrStrings,sampleRate)
%%  % helicalAxisCalc() calcualte the mena helical axis of the knee 
    % Authors: Peter Mills, David Saxby, Thor Besier. adapted by J.Dunne
    %   Calculate mean helical axis for left knee using 
    
    % Reoder the parent and child structures
        parentMkrStruct  = reorderStruct(MkrStruct, parentMkrStrings );    
        childMkrStruct   = reorderStruct(MkrStruct, childMkrStrings );
    % Dump out the Marker data in the Parent markers local 
    % coordinate system. Make sure its only 3 parent markers and 3 child
    % markers. Any more will cause the function to crash down stream. 
        parentMkrsInLocal  = coordinateSystemTransform('local', parentMkrStruct(1:3),parentMkrStruct(1:3));
        childMkrInLocal    = coordinateSystemTransform('local', parentMkrStruct(1:3),childMkrStruct(1:3));
    
    % MEANHELICALAXIS calculates instantaneous helical axes using the technique
    % described by Stokdijk et al. (1999). ClinBiomech, 14 , 177-84.
    [Nopt, Sopt, unitVectorArray, pivotPointArray, IHAIndex] = meanhelicalaxis_splines(parentMkrsInLocal, childMkrInLocal, sampleRate, 10, 'y', 1, 1);

    %   Scale helical axis vector
    half_knee_width = 100;

    %   Generate a helical axis vector
    for i = 1:length(IHAIndex)
        helical_axis_vector_series(i,:) =(half_knee_width/unitVectorArray(i,1)) * unitVectorArray(i,:);
    end
    helical_axis_vector =(half_knee_width / Nopt(1)) * Nopt;
    HA1 = Sopt - helical_axis_vector;
    HA2 = Sopt + helical_axis_vector;
    HA1_v = pivotPointArray - helical_axis_vector_series;
    HA2_v = pivotPointArray + helical_axis_vector_series;
    
end

function HJC = hipJointCenter(parentStruct,childNameArray)
    % Reoder the left thigh (child) structure
            childMkrStruct  = reorderStruct(parentStruct,  childNameArray );
    % Dump out the Child marker data in the Parent markers local
    % coordinate system
            [childMkrsInLocal] = coordinateSystemTransform('local', parentStruct,[childMkrStruct(1).data childMkrStruct(2).data childMkrStruct(3).data],1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % Calculate the center of rotation of the child markers 
            [HJC] = sphericalFitting(childMkrsInLocal);      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end












