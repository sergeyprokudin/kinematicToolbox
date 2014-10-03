function [JC_location] = findballjointcentre(prox_mkr_trajectories,dist_mkr_trajectories)

% Create xyz 3D column arrays for each prox or distal marker from coord data input


prox_mkr1 = prox_mkr_trajectories(1).Data;
prox_mkr2 = prox_mkr_trajectories(2).Data;
prox_mkr3 = prox_mkr_trajectories(3).Data;
dist_mkr1 = dist_mkr_trajectories(1).Data;
dist_mkr2 = dist_mkr_trajectories(2).Data;
dist_mkr3 = dist_mkr_trajectories(3).Data;
    
nFrames = size(dist_mkr3,1);

% Define the prox origin as the average of the prox markers
origin=(prox_mkr2+prox_mkr1+prox_mkr3 )/3;

% Calculate unit vectors of Pelvis origin relative to global
[e1Proximal,e2Proximal,e3Proximal]=segmentorientationV2V1(prox_mkr1-prox_mkr3,prox_mkr2-origin);

% PreAllocate memory to save time
DistMrk1_ProxCS = zeros(nFrames,3);
DistMrk2_ProxCS = zeros(nFrames,3);
DistMrk3_ProxCS = zeros(nFrames,3);

% Transform the prox and dist marker points into the pelvis coordinate system
for i=1:nFrames
    rotationmatrix=[e1Proximal(i,:);e2Proximal(i,:);e3Proximal(i,:)];
    originvector=origin(i,:)';
    DistMrk1_ProxCS(i,:)=(rotationmatrix*(dist_mkr1(i,:)')-rotationmatrix*originvector)';
    DistMrk2_ProxCS(i,:)=(rotationmatrix*(dist_mkr2(i,:)')-rotationmatrix*originvector)';
    DistMrk3_ProxCS(i,:)=(rotationmatrix*(dist_mkr3(i,:)')-rotationmatrix*originvector)';
    
    prox_mkr1Pelvis(i,:)=(rotationmatrix*(prox_mkr1(i,:)')-rotationmatrix*originvector)';
    prox_mkr2Pelvis(i,:)=(rotationmatrix*(prox_mkr2(i,:)')-rotationmatrix*originvector)';
    prox_mkr3Pelvis(i,:)=(rotationmatrix*(prox_mkr3(i,:)')-rotationmatrix*originvector)';
    
end


% Calculate the joint center in the prox coordinate system
DistMarkersInProxCS=[DistMrk1_ProxCS DistMrk2_ProxCS DistMrk3_ProxCS];
[JC_location]=calc_JC(DistMarkersInProxCS);


% Plot the prox and distal marker locations and the joint center in the pelvis coordinate system
% hold on
% plot3(prox_mkr1Pelvis(:,1),prox_mkr1Pelvis(:,2),prox_mkr1Pelvis(:,3),'ro')
% plot3(prox_mkr2Pelvis(:,1),prox_mkr2Pelvis(:,2),prox_mkr2Pelvis(:,3),'go')
% plot3(prox_mkr3Pelvis(:,1),prox_mkr3Pelvis(:,2),prox_mkr3Pelvis(:,3),'bo')
% plot3(DistMrk1_ProxCS(:,1),DistMrk1_ProxCS(:,2),DistMrk1_ProxCS(:,3),'ro')
% plot3(DistMrk2_ProxCS(:,1),DistMrk2_ProxCS(:,2),DistMrk2_ProxCS(:,3),'go')
% plot3(DistMrk3_ProxCS(:,1),DistMrk3_ProxCS(:,2),DistMrk3_ProxCS(:,3),'bo')
% plot3(JC_location(1,1),JC_location(2,1),JC_location(3,1),'kx')
% % Plot the axis
% plot3(0,0,0,'ko')
% plot3(100,0,0,'ro')
% plot3(0,100,0,'go')
% plot3(0,0,100,'bo')
% axis equal
% 
% hold
% 
% pause
% close


%-------------------------------------------------
% Function: segmentorientationV1V3
%  Calculates a unit vector coordinate frame for two vectors V1 and V3
%-------------------------------------------------
function [e1,e2,e3] = segmentorientationV1V3(V1,V3)

e1 = zeros(length(V1),3);
e2 = zeros(length(V1),3);
e3 = zeros(length(V1),3);

for i=1:length(V1)
   e1(i,:)=V1(i,:)/sqrt(dot(V1(i,:),V1(i,:)));
   e3(i,:)=V3(i,:)/sqrt(dot(V3(i,:),V3(i,:)));
end

for i=1:length(V1)
   e2(i,:) = cross(e3(i,:),e1(i,:));
end

for i=1:length(V1)
   e3(i,:) = cross(e1(i,:),e2(i,:));
end

%-------------------------------------------------
% Function: segmentorientationV2V1
%  Calculates a unit vector coordinate frame for two vectors V1 and V2
%-------------------------------------------------
function [e1,e2,e3] = segmentorientationV2V1(V2,V1)

e1 = zeros(length(V1),3);
e2 = zeros(length(V1),3);
e3 = zeros(length(V1),3);

for i=1:length(V1)
   e1(i,:)=V1(i,:)/sqrt(dot(V1(i,:),V1(i,:)));
   e2(i,:)=V2(i,:)/sqrt(dot(V2(i,:),V2(i,:)));
end

for i=1:length(V1)
   e3(i,:) = cross(e1(i,:),e2(i,:));
end

for i=1:length(V1)
   e1(i,:) = cross(e2(i,:),e3(i,:));
end


function [Cm]=calc_JC(TrP)
% ------------------------------------------------------------------------------------------
% Description: Calculation of the hip joint center HJC.
% [Cm]=calc_HJC(TrP).
% ------------------------------------------------------------------------------------------
% INPUT: TrP clean matrix containing markers'trajectories in the proximal system of reference.
%            dim(TrP)=Nc*3p where Nc is number of good samples and p is the number of distal markers
% OUTPUT: Cm vector with the coordinates of hip joint center (Cx,Cy,Cz).
%------------------------------------------------------------------------------------------
% Comments: metodo1b extracts HJC position as the centre of the optimal spherical suface that minimizes the root mean square error 
%           between the radius(unknown) and the distance of the centroid of marker's coordinates from sphere center(unknown).
%           Using edfinition of vector differentiation is it possible to put the problem in the form: A*Cm=B that is a
%           linear equation system
% References: Gamage, Lasenby J. (2002). 
%             New least squares solutions for estimating the average centre of rotation and the axis of rotation.
%             Journal of Biomechanics 35, 87-93 2002   
%             Halvorsen correzione bias
% Author Andrea Cereatti.
% Date
%------------------------------------------------------------------------------------------
[r c]=size(TrP);
D=zeros(3);
V1=[];
V2=[];
V3=[];
b1=[0 0 0];
for j=1:3:c
    d1=zeros(3);
    V2a=0;
    V3a=[0 0 0];
    for i=1:r 
        d1=[d1+TrP(i,j:j+2)'*(TrP(i,j:j+2))];       %  dim(b)=3*3
        a=(TrP(i,j).^2+TrP(i,j+1).^2+TrP(i,j+2).^2);
        V2a=V2a+a;     % dim(V2a)=1
        V3a=V3a+a*TrP(i,j:j+2);     %dim(V3a)=1*3
    end
    D=D+(d1/r);     %  dim(D)=3*3
    V2=[V2,V2a/r];  % dim(V2a)=1*p    
    b1=[b1+V3a/r];      % dim(b1)=1*3
end
V1=mean(TrP);      % dim(V1)=1*(3P)
 p=size(V1,2);
 e1=0;
 E=zeros(3);
 f1=[0 0 0];
 F=[0 0 0];
 for k=1:3:p
     e1=V1(k:k+2)'*V1(k:k+2);       %dim(e1)=3*3
     E=E+e1;     % dim(E)=3*3
     f1=V2((k-1)/3+1)*V1(k:k+2);       %dim(f)=1*3
     F=F+f1;      %dim(F)=1*3
 end
% equation (5) of Gamage and Lasenby
A=2*(D-E);      %dim(A)=3*3
B=(b1-F)';         %dim(B)=3*1
[U,S,V] = svd(A);
Cm_in=V*inv(S)*U'*B;
Cm_old=Cm_in+[1,1,1]';
kk=0;
while distance(Cm_old',Cm_in')>0.0000001
    Cm_old=Cm_in;
    sigma2=[];
    for j=1:3:c
        marker=TrP(:,j:j+2);
        Ukp=marker-(Cm_in*ones(1,r))';
        % computation of u^2
        u2=0;
        app=[];
        for i=1:r
            u2=u2+Ukp(i,:)*Ukp(i,:)';
            app=[app,Ukp(i,:)*Ukp(i,:)'];
        end
        u2=u2/r;
        % computation of sigma
        sigmaP=0;
        for i=1:r
            sigmaP=sigmaP+(app(i)-u2)^2;
        end
        sigmaP=sigmaP/(4*u2*r);
        sigma2=[sigma2;sigmaP];
    end
    sigma2=mean(sigma2);
    % computation of deltaB
    deltaB = 0;
    for j=1:3:c
        deltaB=deltaB + V1(j:j+2)'-Cm_in;
    end
    deltaB=2*sigma2*deltaB;
    Bcorr=B-deltaB; % corrected term B
    % iterative estimation  of the centre of rotation
    [U,S,V] = svd(A);
    Cm_in=V*inv(S)*U'*Bcorr;
end
Cm=Cm_in;



function [dist]=distance(XYZmarker1,XYZmarker2)
% function [dist]=distance(XYZmarker1,XYZmarker2)
% Description:	Calculates the distance between two markers.
% Input:	XYZmarker1: [X,Y,Z] coordinates of marker 1
%		XYZmarker2: [X,Y,Z] coordinates of marker 2
%		Note: The distances are calculated for each row
% Output:	distance
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
% Date:		November, 1996
% Last Changes:	November 29, 1996
% Version:	1.0
		

[s1,t1]=size(XYZmarker1);
[s2,t2]=size(XYZmarker2);

if s1~=s2 | t1~=t2 | t2~=3
 disp('The input matrices must have 3 columns and the same number')
 disp('of rows. Try again.')
 return
end

tmp=[XYZmarker1-XYZmarker2].^2;
dist=[sum(tmp')'].^0.5;

