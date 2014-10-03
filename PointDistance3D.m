function [distance] = PointDistance3D(Point1,Point2,Frames)
%UNTITLED2 Summary of this function goes here
%   As this is function was initially used to look at the distance between
%   a virtual foot marker (sampling rate=250Hz) and the COP (sampling
%   Rate=2000Hz) weneed to upsample the marker data first before we compare
%   distances. (Point1 was the Marker and Point 2 was the COP)







  x=[1:length(Point1)];
  xx=[0:length(Point1)/length(Point2) :length(Point1)];
  [m n]=size(Point1);
  Point1_up=zeros(length(xx),n);
  for uu=1:n
      Point1_up(:,uu) = spline(x,Point1(:,uu),xx);
  end

dx=Point1_up(Frames,1)-Point2(Frames,1);
dy=Point1_up(Frames,2)-Point2(Frames,2);
dz=Point1_up(Frames,3)-Point2(Frames,3);
distance = sqrt(dx.^2 + dy.^2 + dz.^2);



end

