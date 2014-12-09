function newStationData = stationInFrame(data,frameOrigin, frameOrient, stations, moveTo)
% 
% data          A structure with such that data.RTH1 = nX3 matrix
% frameOrigin   A nX3 matrix of values which represent a 3d point in global
% frameOrient   A nX9 matrix of values for an orthoganal frame
% stations      A cell of existing strings in data ie {'RTH1' 'RTH2'}
%               or a cell of data {nX3}
% moveTo        either 'global' or 'local'
% 

if ~isempty(find(cellfun(@isnumeric, stations), 1))
   % set the variable to be used later 
   % stationName = stations(cellfun(@isstr, stations)) ;
   dataArray = cell2mat(stations(cellfun(@isnumeric, stations)));
   nStations = size(dataArray,2)/3;
    
else 
    % set the variable to be used later
    stationName = stations;
    nStations = length(stations);
    dataArray = zeros(length(frameOrient),length(stations)*3);
    
    for i = 1 :  nStations
        dataArray(:,3*i-2:3*i) = data.(stations{i});
    end
end



for u = 1 : 3 : nStations*3
    
    for i = 1 : length( frameOrient)
        % set the instantaneous rotation matrix from the frame orientation
        rotationmatrix=[frameOrient(i,1:3);frameOrient(i,4:6);frameOrient(i,7:9)]; 

        if strcmp(moveTo,'global')
            % invert the rotation matrix
            rotationmatrix=inv(rotationmatrix); 
            % rotate into the global frame
            newStationData(i,u:u+2)= rotationmatrix*(dataArray(i,u:u+2)') + frameOrigin(i,:)';

        elseif strcmp(moveTo,'local')
            % Rotate stations into the local frame 
            newStationData(i,u:u+2)=(rotationmatrix*(dataArray(i,u:u+2)')-rotationmatrix*frameOrigin(i,:)')';
        else 
            error('input is incorrect, strings must either written; global or local')
        end
   end
end



end

