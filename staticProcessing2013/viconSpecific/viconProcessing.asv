function viconProcessing

%% Interact with Vicon Pecs server
global  hServer;
global  hTrial;
global  hProcessor;
global  hParamStore;
global  hEvStore;
hServer = actxserver( 'PECS.Document' );
invoke( hServer, 'Refresh' );
hTrial = get(hServer, 'Trial' );
hProcessor = get(hServer, 'Processor' );
hParamStore = get(hTrial, 'ParameterStore' );
hEvStore = get(hTrial, 'EventStore' );

%% Create strucutre with all marker names in the trial 
[mkrStruct,trialName, dataPath,analogRate,sampleRate,firstFrame,lastFrame]  =  c3dPecsData(hTrial);

%% Read in marker storage .xml
% This marker file will have the storage strings necessary to do analysis
% Also stores the position of Virtual marker's in the local technical frame
mkrFileInfo = xml_read(fullfile(dataPath, 'mkrFile.xml'));




%% Pointer trial
if ~isempty(strfind(lower(trialName),'pointer')); 
   % Define the body name of your pointer device located in mkrFile.xml 
   pointerBodyName = 'pointer';
   % run pointer code
   [pointInLTCS parentMarkers] = pointerTrial(mkrStruct,trialName,dataPath,pointerBodyName,mkrFileInfo);
   % Save (global) point 2 C3D file
   save2C3D(hTrial,parentMarkers,trialName,pointInLTCS,firstFrame,lastFrame);
end

%% Functional Trial
if ~isempty(strfind(lower(trialName),'fun'));
    
    % These names are order dependant and must match up with the names in 
    % mkrFileInfo. Place in order of 'pelvis' 'l.thigh' 'l.tibia'
    % 'r.thigh' 'r.tibia'. 
    bodyNames = {'pelvis' 'l.thigh' 'l.tibia' 'r.thigh' 'r.tibia'};
    
    
    
    % Run Functional code
    [pointData pointName parentMkrStruct] = functionalAnalysis( mkrStruct,...
                                                trialName,...
                                                dataPath,...
                                                firstFrame,...
                                                lastFrame,...
                                                sampleRate,...
                                                bodyNames,...
                                                mkrFileInfo);
    
    % Print pointData from  functionalAnalysis to C3D file (vicon Pecs)
    for i = 1:length(pointName)
        if ~isempty(strfind(lower(trialName),'hip'));
            save2C3D(hTrial,parentMkrStruct,char(pointName(i)),pointData(i,:),firstFrame,lastFrame,1);  
        end  

        if ~isempty(strfind(lower(trialName),'knee'));
            if i == 1 || i ==2
                u = 1;
            else
                u = 2;
            end
            
            save2C3D(hTrial,parentMkrStruct(u,:),char(pointName(i)),pointData(i,:),firstFrame,lastFrame);  
        end 
    end
    
end


%% Static Trial
if ~isempty(strfind(lower(trialName),'static'));
    
     
    % Dump markers in the XML out into the C3D. This is only needed if you
    % use pointer markers or any other type of marker that may be need
    % later. 
        appendXML2Static(hTrial,mkrStruct,trialName,dataPath,firstFrame,lastFrame,sampleRate,mkrFileInfo) 
    
    % Hips (orthotrack regression 
        % mkrRadius is the size, in mm, of the experimental markers.
        mkrRadius = 12;
        bodyName = 'pelvis';
        % Regression equation hip
        [regressionLHJC regressionRHJC pelvisMkrStruct] = regressionHJC(mkrStruct,dataPath,sampleRate,mkrFileInfo,mkrRadius,bodyName);
        % Save hip points to C3d 
        LHJCregressionGB= save2C3D(hTrial,pelvisMkrStruct,'LHJCregression',regressionLHJC,firstFrame,lastFrame,1);
        RHJCregressionGB= save2C3D(hTrial,pelvisMkrStruct,'RHJCregression',regressionRHJC,firstFrame,lastFrame,1);
    
    % Update the mkrStruct & mkrFileInfo files 
        mkrStruct  =  c3dPecsData(hTrial);
        mkrFileInfo = xml_read(fullfile(dataPath, 'mkrFile.xml'));    
    
    % Knee calibration
        bodyNames = {'l.thigh' 'r.thigh'};
        % Run the knee calibration section. 
        % Pointer    = false
        % functional = true
        for i = 1: length(bodyNames)
          [mkrFileInfo] =  jointCalibration(mkrStruct,dataPath,bodyNames(i),mkrFileInfo,true,true);
        end
    % Ankle calibration
        % Define the body names for the knee
        bodyNames = {'l.tibia' 'r.tibia'};
        % Run the ankle calibration section. 
        % Pointer    = false
        % functional = false
        for i = 1: length(bodyNames)
              [mkrFileInfo] =  jointCalibration(mkrStruct,dataPath,bodyNames(i),mkrFileInfo, false, false);
        end
        
    % Updated C3D
        mkrFileInfo = xml_read(fullfile(dataPath, 'mkrFile.xml'));
        appendXML2Static(hTrial,mkrStruct,trialName,dataPath,firstFrame,lastFrame,sampleRate,mkrFileInfo) 
       
        
    % Foot calibration markers 
        bodyNames = {'l.foot' 'r.foot'};
        %jointCalibration(mkrStruct,dataPath,bodyNames(i),mkrFileInfo, false, false);
    
    
end 


%% End Pecs

release( hEvStore );
release( hParamStore );
release( hProcessor );
release( hTrial );
release( hServer );
end








