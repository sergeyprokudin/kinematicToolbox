function [ Lmarker ] = MarkerinLocalSystem(Csystem,Omarker,Gmarker)
%%GlobalToTechnicalCoordinateSytem- Move a marker from its global
	%coordinates to the parent technical coodinate frame
	%Author: Thor Besier & James Dunne. 
	% 
	%   Csystem             Calculated Coordinate system
    %   Omarker             Orgin of Coodinate system (Global)
    %   Gmarker             Marker location in global
    
% Author:  James Dunne
% Created: Feburary 2010
% Last Updated: Jan 2013

%Number of frames
	nFrames = length(Gmarker);

%Define the prox origin as the average of the prox markers
	origin=Omarker;

% Define individual vectors of the coordinate system
	e1Proximal=Csystem(:,1:3);
    e2Proximal=Csystem(:,4:6);
    e3Proximal=Csystem(:,7:9);
 
% PreAllocate memory to save time
	Mkr_in_local = zeros(nFrames,3);

% Transform the Marker global coordinates into local coordinates
	for i=1:nFrames
		rotationmatrix=[e1Proximal(i,:);e2Proximal(i,:);e3Proximal(i,:)];
		originvector=origin(i,:)';
		Mkr_in_local(i,:)=(rotationmatrix*(Gmarker(i,:)')-rotationmatrix*originvector)';
    end

% get a single position value for all three x,y and z     
    	Lmarker=mean(Mkr_in_local);

end


































