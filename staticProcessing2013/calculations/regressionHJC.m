function [ regressionLHJC regressionRHJC pelvisMkrStruct] = regressionHJC(mkrStruct,dataPath,sampleRate,mkrFileTree,mkrRadius,bodyName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



%% Filter marker Data (butterworth)
    filtMkrStruct = filterData(8,4,sampleRate,mkrStruct);
%% Process the data structure to get RASI, LASI and SACR in the first three
%  cells
  % Pelvis markers
    [bodyMkrs mkrFileTree]            = mkrFileSearch(mkrFileTree,'pelvis');

  % Order the pelvis in the structure
    [pelvisMkrStruct] = pelvisOrder(mkrStruct,bodyMkrs.expMkrs);
%%
 % Dump out the Child marker data in the Parent markers local
 % coordinate system
    [pelvisMkr1] = coordinateSystemTransform('local', pelvisMkrStruct,pelvisMkrStruct(1).data, 1);
    [pelvisMkr2] = coordinateSystemTransform('local', pelvisMkrStruct,pelvisMkrStruct(2).data, 1);
    [pelvisMkr3] = coordinateSystemTransform('local', pelvisMkrStruct,pelvisMkrStruct(3).data, 1);
    
    % calculated the above child points using the origin at center of ALL
    % three markers. However the regression equation uses the midpelvis as
    % the origin. Here, we calculate the offset between in the two in the x
    % axis and apply it to the markers. Then, at the the end we will add
    % the offset back on 
    originOffset = mean([mean(pelvisMkr1(:,1));mean(pelvisMkr2(:,1))]);
    
    pelvisMkr1(:,2) = 0; pelvisMkr2(:,2) = 0; pelvisMkr3(:,2) = 0;
    
    pelvisMkr1(:,1) = pelvisMkr1(:,1) -originOffset ;
    pelvisMkr2(:,1) = pelvisMkr2(:,1) -originOffset ;
    pelvisMkr3(:,1) = pelvisMkr3(:,1) -originOffset ;
    
 % Calculate an origin
    pelvisOrigin=(pelvisMkr1+pelvisMkr2)/2; 

 % Calculate the distance between the ASIS markers      
    InterASISDist=mean(markerDistance(pelvisMkr1,pelvisMkr2));
    
 % Use the regression equation to calculate the HJC's
    coordinateLHJC = [(-0.21*InterASISDist)-mkrRadius -(0.32*InterASISDist)   0.34*InterASISDist];
    coordinateRHJC = [(-0.21*InterASISDist)-mkrRadius -(0.32*InterASISDist)   -0.34*InterASISDist];

 % Add the HJC coordinate to the midpelvis origin
    regressionLHJC=[pelvisOrigin(:,1)+coordinateLHJC(:,1) pelvisOrigin(:,2)+coordinateLHJC(:,2) pelvisOrigin(:,3)-coordinateLHJC(:,3) ];
    regressionRHJC=[pelvisOrigin(:,1)+coordinateRHJC(:,1) pelvisOrigin(:,2)+coordinateRHJC(:,2) pelvisOrigin(:,3)-coordinateRHJC(:,3) ];

% Get the position displacement
    regressionLHJC=mean(regressionLHJC);
    regressionRHJC=mean(regressionRHJC);
    
% Shift data back into the Pelvic origin
    regressionLHJC(:,1) = regressionLHJC(:,1) +originOffset;
    regressionRHJC(:,1) = regressionRHJC(:,1) +originOffset;    
    
 %% Print the updated Marker .xml to subject foler. 
    
 % Access the names of the parent markers for this point given the trialname   
    [bodyMkrs mkrFileTree]...
           = mkrFileSearch(mkrFileTree, 'LHJCregression', regressionLHJC);
           
    [bodyMkrs mkrFileTree]...
           = mkrFileSearch(mkrFileTree, 'RHJCregression', regressionRHJC);       
 
    wPref.StructItem = false; 
    xml_write(fullfile(dataPath, 'mkrFile.xml'), mkrFileTree, 'MarkerSet',wPref);
    
   
    


end

