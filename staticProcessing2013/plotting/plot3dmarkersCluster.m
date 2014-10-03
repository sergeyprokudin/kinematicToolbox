function plot3dmarkersCluster(Markercluster3D, color)
%% plot3dmarkersCluster() plots the 3d locations of a marker cluster.
%   3DMarkerLcluster is a strucutre of markers
%   color is a string defining the color of the plotted points


if isstruct(Markercluster3D) % Check to see if data has been sent as a structure
   for i=1:length(Markercluster3D)
       hold on
       markerData = Markercluster3D(i).Data;
       plot3(markerData(:,1),markerData(:,2),markerData(:,3),color);
   end 
else ~isstruct(Markercluster3D);
  [m n] = size(Markercluster3D);
    if ~mod(n,3)
        for i=1:n/3
            hold on
            plot3(Markercluster3D(:,(i*3)-2),Markercluster3D(:,(i*3)-1),Markercluster3D(:,(i*3)),color);
        end
    else    
       disp('cannot plot data. Not enough Colms')
    end    
end


end