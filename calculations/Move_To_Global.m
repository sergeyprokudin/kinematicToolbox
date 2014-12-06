function stationInNewFrame = stationRelativeFrameChange(frameLocation, frameOrientation, station)


rem(size(station,2),3)


% Transform the global position of the marker to technical
for i = 1 : length(station)
    % At each data point (i) define...
    % the rotationMatrix
    rotationmatrix = [frameOrientation(i,1:3);frameOrientation(i,4:6);frameOrientation(i,7:9)]; 
    % the origin
    originvector = frameLocation(i,:)';                                        

    if strcmp(moveTo,'global')
        % Invert the rotation matrix,
        rotationmatrix=inv(rotationmatrix); 
        % Rotate the data and offset the TCS origin
        stationInNewFrame(i,:)= rotationmatrix*(mkr(i,:)') + originvector;
    elseif strcmp(moveTo,'local')
        % Rotate the data and offset the TCS origin
        stationInNewFrame(i,:)=(rotationmatrix*(mkr(i,:)')-rotationmatrix*originvector)';
    else 
        error('input is incorrect, must either be strings global or local')
    end
end


end





