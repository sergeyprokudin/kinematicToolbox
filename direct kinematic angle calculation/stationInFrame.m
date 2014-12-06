function newStations = stationInFrame(data,frameOrigin, frameOrient, stations, moveTo)

newStations = zeros(size(data.(stations{1})));

for u = 1 : length(stations)
    % Transform the global position of the station to technical
    for i = 1 : length(data.(stations{u}))
        
        % Define the rotation matrix from the frame orientation data        
        rotationmatrix=[frameOrient(i,1:3);frameOrient(i,4:6);frameOrient(i,7:9)]; 

        % the origin
        if strcmp(moveTo,'global')
        
            % Invert the rotation matrix and rotate
            rotationmatrix=inv(rotationmatrix); 
            newStationData(i,:)= rotationmatrix*(data.(stations{u})(i,:)') + frameOrigin(i,:)';

        elseif strcmp(moveTo,'local')
        
            % Rotate the data and offset the TCS origin
            newStationData(i,:)=(rotationmatrix*(data.(stations{u})(i,:)')-rotationmatrix*frameOrigin(i,:)')';
        
        else 
        
            error('input is incorrect, must either be strings global or local')
        end
    
    end
 
    % Appened the newStationData into an array
    %     if u == 1;
    %         newStations = struct(['station' num2str(u)],{newStationData});
    %     else
    %         eval(['newStations.station' num2str(u) ' = newStationData;'])
    %     end
    if u == 1
        newStations = newStationData;
    else
        newStations = [newStations newStationData];
    end


end



end

