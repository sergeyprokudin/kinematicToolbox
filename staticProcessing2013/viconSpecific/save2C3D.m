function [globalvMkrArray]= save2C3D(hTrial,parentMkrStruct,localPointName,vMkr,firstFrame,lastFrame,v1v3)
    % save2C3D stores a 3D point in the C3D structure
    % save2C3D() takes the position of a point (in the local) and writes that
    % point to the C3D file for storage and visualization. 
      
    
    % Examine the size/shape of the data
    [nRow nColm]= size(vMkr);
    if nRow*nColm == 3                  % If data is a single vector (3x1 or 1x3)
        if nRow>nColm  % if a 1x3 matrix
                vMkrArray= repmat(vMkr',[length(firstFrame:lastFrame) 1]);
        else           % if a 3x1 matrix
                vMkrArray= repmat(vMkr,[length(firstFrame:lastFrame) 1]);
        end
    else
        disp([localPointName ': nRow' nRow ' nColm=' nColm 'Cannot save marker location to C3D please check size of array in save2C3D()'])
            return
    end
        
     % Move to the global coordinate system V1V2
     if nargin == 6 
            [globalvMkrArray] = coordinateSystemTransform('global', parentMkrStruct,vMkrArray);
     end
    
    
    % Move to the global coordinate system V1V3  
    if nargin == 7 
        if v1v3 == 1
            [globalvMkrArray] = coordinateSystemTransform('global', parentMkrStruct,vMkrArray,1);
        else
            [globalvMkrArray] = coordinateSystemTransform('global', parentMkrStruct,vMkrArray);
        end        
    end
    

    hTrajectory = invoke(hTrial, 'CreateTrajectory'); % Access the CreateTrajectory class
    set(hTrajectory,'Label',char(localPointName));    % Create a Trajectory object
    invoke(hTrajectory,'SetPoints',firstFrame,lastFrame,globalvMkrArray'); % Populate the Trajectory object
    release(hTrajectory);                             % Release the object
end