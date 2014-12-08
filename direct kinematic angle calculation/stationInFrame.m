function newStations = stationInFrame(data,frameOrigin, frameOrient, stations, moveTo)


if ~isempty(find(cellfun(@isnumeric, stations), 1))
    
   stationName = char( stations(cellfun(@isstr, stations))) ;
   dataArray = cell2mat( stations(cellfun(@isnumeric, stations)));
   nStations =  1;
    
    
else 

    nStations = length(stations);
    dataArray = zeros(length(frameOrient),length(stations)*3);
    
    for i = 1 :  nStations
        dataArray(:,3*i-2:3*i) = data.(stations{i});
    end
end

for u = 1 : 3 : nStations*3
    % Transform the global position of the station to technical
    for i = 1 : length( frameOrient)
        
        % Define the rotation matrix from the frame orientation data        
        rotationmatrix=[frameOrient(i,1:3);frameOrient(i,4:6);frameOrient(i,7:9)]; 

        % the origin
        if strcmp(moveTo,'global')
        
            % Invert the rotation matrix and rotate
            rotationmatrix=inv(rotationmatrix); 
            newStationData(i,u:u+2)= rotationmatrix*(dataArray(i,u:u+2)') + frameOrigin(i,:)';

        elseif strcmp(moveTo,'local')
        
            % Rotate the data and offset the TCS origin
            newStationData(i,:)=(rotationmatrix*(data.(stations{u})(i,:)')-rotationmatrix*frameOrigin(i,:)')';
        
        else 
        
            error('input is incorrect, must either be strings global or local')
        end
    
    end

    if u == 1
        newStations = newStationData;
    else
        newStations = [newStations newStationData];
    end

end



end

