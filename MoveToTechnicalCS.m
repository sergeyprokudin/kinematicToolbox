function [ ChildMrk_TechCS ] = MoveToTechnicalCS(Prox_mkrStruct, ChildMarkerData)
%%GlobalToTechnicalCoordinateSytem- Move a marker from its global
	%coordinates to the parent technical coodinate frame
	%Author: Thor Besier & James Dunne. 
	% 
	%   MarkerSturct        marker structure, with proximal markers in
	%                       cells 1,2 and 3
    %   VirtualMarkerName   x,y,z data for a marker which you want to hold
    %                       in a created technical coordinate system
	
    
    
% Author: Thor Besier and James Dunne
% Created: Feburary 2010
% Last Updated: May 2011

    if isstruct(Prox_mkrStruct)
            prox_mkr1=Prox_mkrStruct(1).Data;
			prox_mkr2=Prox_mkrStruct(2).Data;
			prox_mkr3=Prox_mkrStruct(3).Data;
    else
            prox_mkr1=Prox_mkrStruct(:,1:3);
			prox_mkr2=Prox_mkrStruct(:,4:6);
			prox_mkr3=Prox_mkrStruct(:,7:9);
    end
    
    [m n]=size(ChildMarkerData);
    [m1 n1]=size(prox_mkr1);
    if m==1
        dist_mkr1=repmat(ChildMarkerData,m1,1);
    else
        dist_mkr1=ChildMarkerData;
    end
    
%define the proximal marker positions....willl need to make this generic
	nFrames = length(prox_mkr1);

%Define the prox origin as the average of the prox markers
	origin=(prox_mkr2+prox_mkr1+prox_mkr3 )/3;

% Calculate unit vectors of Pelvis origin relative to global
	[e1Proximal,e2Proximal,e3Proximal]=segmentorientationV2V1(prox_mkr1-prox_mkr3,prox_mkr2-origin);
 
% PreAllocate memory to save time
	DistMrk1_ProxCS = zeros(nFrames,3);


% Transform the prox and dist marker points into the parent coordinate system
	for i=1:nFrames
		rotationmatrix=[e1Proximal(i,:);e2Proximal(i,:);e3Proximal(i,:)];
		originvector=origin(i,:)';
		DistMrk1_ProxCS(i,:)=(rotationmatrix*(dist_mkr1(i,:)')-rotationmatrix*originvector)';
    end

% get a single position value for all three x,y and z     
    	ChildMrk_TechCS=mean(DistMrk1_ProxCS);

end


































