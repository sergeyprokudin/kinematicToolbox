function [ ChildMrk_TechCS ] = MoveToTechnicalCS(cluster, ChildMarkerData)
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

    if isstruct(cluster)
            clusterMkr1=cluster(1).Data;
			clusterMkr2=cluster(2).Data;
			clusterMkr3=cluster(3).Data;
    else
            clusterMkr1=cluster(:,1:3);
			clusterMkr2=cluster(:,4:6);
			clusterMkr3=cluster(:,7:9);
    end
    
    [m n]=size(ChildMarkerData);
    [m1 n1]=size(clusterMkr1);
    if m==1
        dist_mkr1=repmat(ChildMarkerData,m1,1);
    else
        dist_mkr1=ChildMarkerData;
    end
    
%define the proximal marker positions....willl need to make this generic
	nFrames = length(clusterMkr1);

%Define the prox origin as the average of the prox markers
	origin=(clusterMkr2+clusterMkr1+clusterMkr3 )/3;

% Calculate unit vectors of Pelvis origin relative to global
	[e1Proximal,e2Proximal,e3Proximal]=segmentorientationV2V1(clusterMkr1-clusterMkr3,clusterMkr2-origin);
 
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


































