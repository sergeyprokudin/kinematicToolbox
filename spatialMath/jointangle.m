function [Erotations] = jointangle(frame1,frame2,type)
% Calculates the 3D angle between cordinate frame 1 and 2.
% Author: J.Dunne (dunne.jimmy@gmail.com)
% Date: September 2012.


Erotations=zeros(length(frame1),3);

for ii=1:length(frame1)
    
    %  rotation of A in ground
    R_AG=[frame1(ii,1:3);frame1(ii,4:6);frame1(ii,7:9)];
    

    %  rotation of B in ground
    R_BG=[frame2(ii,1:3);frame2(ii,4:6);frame2(ii,7:9)];
    
    %  Rotation matrix between these two is....
    R_RG=R_AG*R_BG';
    
    if nargin == 2
       type = 'zyx';
    end
   
    % Decompose the matrix into eular rotations
    [r1 r2 r3] = dcm2angle(R_RG,type);
   
    % Change from radians to degrees
     [Erotations(ii,:)]=rad2deg([r1 r2 r3]);
end













end

