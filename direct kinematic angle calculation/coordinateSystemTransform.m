function [transformedChildMkrArray] = coordinateSystemTransform(moveTo, localTCSMkrData,childMkr, v1v3)
%%  coordinateSystemTransform() 
%   Transforms the coordinate system of childMkr between local and global
%   coordinates. 

%   moveTo           = string that determines transformation ('global' or 'local')   
%   localTCSMkrData  = structure or Array for three markers that define the
%                      Local technical coordinate system. Uses the first 3
%                      markers given (in either structure or Array)
%   childMkr         = structure or Array for markers that need to be
%                      transoformed. Size of each Marker is assumed to be  
%                      nx3 (n rows by 3 columns)
%
%   Author:James Dunne and Thor Besier; Created:Feb.10 Updated:Nov.13 

% Make sure the data is in array format
    [parentMkrArray,nParentMks]        = data2Array(localTCSMkrData);
    [childMkrArray,nChildMkrs]         = data2Array(childMkr);

% make input string lower case
    moveTo = lower(moveTo);

%% Define the Local technical frame

% Break up the parent marker array into individual variables.
        LTCSmkr1 = parentMkrArray(:,1:3); 
        LTCSmkr2 = parentMkrArray(:,4:6); 
        LTCSmkr3 = parentMkrArray(:,7:9);
% Define the origin of the TCS markers as the midpoint between 
        origin=(LTCSmkr1+LTCSmkr2+LTCSmkr3 )/3;
% Calcualte the unit vectors that define the coordinate system one of 
% either the V2V1 method or the V3V1 method. Default is the V!V2, V3V1 is 
% used if there is a 4th variable (true or 1) entered into the function
if nargin == 3
    % Calculate the unit vectors using the V1V3 method.
    [e1Proximal,e2Proximal,e3Proximal]=segmentorientationV2V1(LTCSmkr1-LTCSmkr3,LTCSmkr2-origin);
elseif nargin == 4 && v1v3 == true
    % Calculate the unit vectors using the V1V3 method.    
    [e1Proximal,e2Proximal,e3Proximal]=segmentorientationV1V3(origin-LTCSmkr3, LTCSmkr1-LTCSmkr2);
end

%% Calculate transformed Marker Coordinates
   % This section is split into either 'moving' the mkr points to a local
   % system from a global, or (inversely) moving a local point to a global. 
   % The difference in coding is minimal but it was maintained as serpate
   % functions (below) to better test reliability and accuracy. 
 
if ~isempty(strfind(moveTo,'local'))
% Moves global coordinates to local technical coordinates
    [transformedChildMkrArray] = move2Local(e1Proximal,e2Proximal,e3Proximal,origin,childMkrArray,nChildMkrs);
end

if ~isempty(strfind(moveTo,'global'))
% moves local technical coordinates to global coordinates  
    [transformedChildMkrArray] = move2global(e1Proximal,e2Proximal,e3Proximal,origin,childMkrArray,nChildMkrs);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mkrArray,nMarkers]=data2Array(MkrData)
%% data2Array() checks data and converts to an array
%  Takes either a structure of marker's or an array of data as inputs. 
%  Checks for type and formats data into array for use by parent function.


mkrArray=[]; % Create an empty array for filling
% Check for if structure
if isstruct(MkrData)                            % If data is structure ? 
    nMarkers        = length(MkrData);          % Define the number of markers
    for ii=1:nMarkers                           % Use the empty array to dump marker Data
        mkrArray=[mkrArray MkrData(ii).data];   % Append each dataSet onto the Array
    end
    return                                      % Return to parent function
end    

[m nColms]= size(MkrData);                      % Find the size of the array                        
if ~isstruct(MkrData) & ~mod(nColms,3)          % Is an array and has 3xNMarker Colm's?
    nMarkers=nColms/3;                          % Define the number of markers
    mkrArray=MkrData;                           % Define the Array
    return                                      % Return to parent function
end

% If not a structure or an array with 3*m colm's the program will terminate 
  error('Data doesnt have correct format (3*m colm). See struct2Array()') 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TransformedMarkerDataArray] =move2Local(e1Proximal,e2Proximal,e3Proximal,origin,mkrs,nMkrs)
%% move2Local() Converts global marker coordinates to local technical
%% coordinates (LTCS)
%       eProximal   = Unit vectors representing the LTCS
%       origin      = Origin of the LTCS
%       mkrs        = Array of marker positions that are to be transformed
%       nMkrs       = Number of Markers to be Transformed.
%
    nFrames                     = length(mkrs);            % number of rows
    TransformedMarkerData       = zeros(nFrames,3);       % Empty matrix
    TransformedMarkerDataArray  =[];                      % Empty array to append TransformedMarkerData
    
    for ii=1:nMkrs
        % For each one of the markers...
        mkr = mkrs(:,(3*ii-2):(3*ii));
        % Transform the global position of the marker to technical
        for i=1:nFrames
            % At each data point (i) define...
            % the rotationMatrix
            rotationmatrix=[e1Proximal(i,:);e2Proximal(i,:);e3Proximal(i,:)]; 
            % the origin
            originvector=origin(i,:)';                                        
            % Rotate the data and offset the TCS origin
            TransformedMarkerData(i,:)=(rotationmatrix*(mkr(i,:)')-rotationmatrix*originvector)';
        end
        % Appened the TransformedMarkerData into an array
        TransformedMarkerDataArray=[TransformedMarkerDataArray TransformedMarkerData];

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TransformedMarkerDataArray]= move2global(e1Proximal,e2Proximal,e3Proximal,origin,mkrs,nMkrs)
%% move2Global() Converts Local marker coordinates to Global 
%       eProximal   = Unit vectors representing the LTCS
%       origin      = Origin of the LTCS
%       mkrs        = Array of marker positions that are to be transformed
%       nMkrs       = Number of Markers to be Transformed. 

    nFrames                     = length(mkrs);            % number of rows
    TransformedMarkerData       = zeros(nFrames,3);       % Empty matrix
    TransformedMarkerDataArray  =[];                      % Empty array to append TransformedMarkerData
    
    for ii=1:nMkrs
        % For each one of the markers...
        mkr = mkrs(:,(3*ii-2):(3*ii));
        % Transform the local position of the marker to global
        for i=1:nFrames
            % At each data point (i) define...
            % the rotationMatrix,
            rotationmatrix=[e1Proximal(i,:);e2Proximal(i,:);e3Proximal(i,:)];
            % Invert the rotation matrix,
            rotationmatrix=inv(rotationmatrix); 
            % the origin,
            originvector=origin(i,:)';
            % Rotate the data and offset the TCS origin
            TransformedMarkerData(i,:)= rotationmatrix*(mkr(i,:)') + originvector;
        end
        % Appened the TransformedMarkerData into an array
        TransformedMarkerDataArray=[TransformedMarkerDataArray TransformedMarkerData];
    end

end























