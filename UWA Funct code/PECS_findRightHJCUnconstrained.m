%   PECS_findRightHJCUnconstrained
%   This version is only to be used with complete swinger trials. It
%   incorporates unconstrained non-linear optimisation to find the hip joint
%   centre. While this unconstrained approach reduces the possibility 
%   of settling on a local minimum, it is not appropriate for walking or running
%   trials in which only small medio-lateral displacement occurs.
%
%
%   Written by Thor Besier
%   Adapted by Peter Mills
%   
%   Change history
%   14 February, 2005:  Adapted front end for use with PECS_OptJC.m
%   14 February, 2005:  Changed from constrained to unconstrained optimisation

%   Define the pelvis orfgin 

originPelvis=(LASI+RASI+SACR)/3;

%   Calculate unit vectors of Pelvis segment relative to global 
[e1Pelvis,e2Pelvis,e3Pelvis]=segmentorientation(LASI-RASI,SACR-(LASI+RASI)/2);

%   Transform the marker points into the pelvis coordinate system
for i=1:length(e1Pelvis)
    rotationmatrix=[e1Pelvis(i,:);e2Pelvis(i,:);e3Pelvis(i,:)];
    originPelvisvector=originPelvis(i,:)';
    RTH1Pelvis(i,:)=(rotationmatrix*(RTH1(i,:)')-rotationmatrix*originPelvisvector)';
    RTH2Pelvis(i,:)=(rotationmatrix*(RTH2(i,:)')-rotationmatrix*originPelvisvector)';
    RTH3Pelvis(i,:)=(rotationmatrix*(RTH3(i,:)')-rotationmatrix*originPelvisvector)';
    SACRPelvis(i,:)=(rotationmatrix*(SACR(i,:)')-rotationmatrix*originPelvisvector)';
    RASIPelvis(i,:)=(rotationmatrix*(RASI(i,:)')-rotationmatrix*originPelvisvector)';
    LASIPelvis(i,:)=(rotationmatrix*(LASI(i,:)')-rotationmatrix*originPelvisvector)';
end

%   Expand arrays to [x y z] format
RTH1xPelvis=RTH1Pelvis(:,1);
RTH1yPelvis=RTH1Pelvis(:,2);
RTH1zPelvis=RTH1Pelvis(:,3);
RTH2xPelvis=RTH2Pelvis(:,1);
RTH2yPelvis=RTH2Pelvis(:,2);
RTH2zPelvis=RTH2Pelvis(:,3);
RTH3xPelvis=RTH3Pelvis(:,1);
RTH3yPelvis=RTH3Pelvis(:,2);
RTH3zPelvis=RTH3Pelvis(:,3);
SACRxPelvis=SACRPelvis(:,1);
SACRyPelvis=SACRPelvis(:,2);
SACRzPelvis=SACRPelvis(:,3);
RASIxPelvis=RASIPelvis(:,1);
RASIyPelvis=RASIPelvis(:,2);
RASIzPelvis=RASIPelvis(:,3);
LASIxPelvis=LASIPelvis(:,1);
LASIyPelvis=LASIPelvis(:,2);
LASIzPelvis=LASIPelvis(:,3);

%   Estimate position of hip joint centre using regression
%   (Shea et al.1997 Gait and Posture 5,157) 

MarkerDiameter = 15;   % 15 mm markers
mm = MarkerDiameter/2;
options=[];

 RHJCinitialxyz = [0;50;0]';


R1=mean(sqrt((RTH1xPelvis-RHJCinitialxyz(1)).^2+(RTH1yPelvis-RHJCinitialxyz(2)).^2+(RTH1zPelvis-RHJCinitialxyz(3)).^2));
R2=mean(sqrt((RTH2xPelvis-RHJCinitialxyz(1)).^2+(RTH2yPelvis-RHJCinitialxyz(2)).^2+(RTH2zPelvis-RHJCinitialxyz(3)).^2));
R3=mean(sqrt((RTH3xPelvis-RHJCinitialxyz(1)).^2+(RTH3yPelvis-RHJCinitialxyz(2)).^2+(RTH3zPelvis-RHJCinitialxyz(3)).^2));

%   Create an x vector of initial guesses for hip xyz coordinates and the sphere radii that best approximate each trajectory about 
%   the current hip location. 
xinitial = [RHJCinitialxyz,R1,R2,R3]


%   Plot pelvis markers, thigh markers, anthropometric estimate of hip joint
%   centre and spheres originating at anthropometrically estimated hip centre
%   with radii defined by the mean distance between anthropometrically estimated 
%   hip joint centre to thigh markers

% figure(1)
% scatter3(RTH1xPelvis,RTH1yPelvis,RTH1zPelvis);
% hold;
% scatter3(RTH2xPelvis,RTH2yPelvis,RTH2zPelvis);
% scatter3(RTH3xPelvis,RTH3yPelvis,RTH3zPelvis);
% scatter3(SACRxPelvis,SACRyPelvis,SACRzPelvis,'r');
% scatter3(LASIxPelvis,LASIyPelvis,LASIzPelvis,'r');
% scatter3(RASIxPelvis,RASIyPelvis,RASIzPelvis,'r');
% plot3(RHJCinitialxyz(1,1), RHJCinitialxyz(1,2), RHJCinitialxyz(1,3),'ro');
% text(RHJCinitialxyz(1,1),RHJCinitialxyz(1,2),RHJCinitialxyz(1,3),'Initial');
% title('Initial Right HJC location. Red Markers - Hip,  Blue Markers - Thigh');
% axis equal;
% axis manual;
% [x1,y1,z1]=sphere(12);
% surface(x1*R1+RHJCinitialxyz(1),y1*R1+RHJCinitialxyz(2),z1*R1+RHJCinitialxyz(3),'EdgeColor',[.6 .6 .6],'FaceColor','none');
% [x2,y2,z2]=sphere(18);
% surface(x2*R2+RHJCinitialxyz(1),y2*R2+RHJCinitialxyz(2),z2*R2+RHJCinitialxyz(3),'EdgeColor',[.75 .75 .75],'FaceColor','none');
% [x3,y3,z3]=sphere(25);
% surface(x3*R3+RHJCinitialxyz(1),y3*R3+RHJCinitialxyz(2),z3*R3+RHJCinitialxyz(3),'EdgeColor',[.9 .9 .9],'FaceColor','none');
% dataOK = menu('Is this data OK??', 'Yes', 'No');
% if dataOK == 2;
%     error('Optimisation aborted by user');
% end

%   Specify volume of cube centered on best guess for hip center
%   within which random initial guesses for staring point will be made
half_cube_size = 20.0;

%   Specify maximum number of iterations and functional evaluations;
%   these are much higher than the MATLAB defaults
max_iter = 1000;
max_feval = 1000;

options = optimset('MaxFunEvals', max_feval, 'MaxIter', max_iter, 'Display', 'off', 'LargeScale', 'off');
warning off

nstarts=3;  %   Number of optimisation runs
fbest = 99999;  % Let fbest be very large to start

%   This section is not required for unconstrained optimisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Set up some constraints for the possible location of the hip joint centre. Allow the HJC to move in a box
%   60 mm across. Also ensure that the radii of the spheres is constrained.
%lb = [RHJCinitialxyz(1)-50 RHJCinitialxyz(2)-50 RHJCinitialxyz(3)-50 50 100 200];
%ub = [RHJCinitialxyz(1)+50 RHJCinitialxyz(2)+50 RHJCinitialxyz(3)+50 200 400 500];

% if walk == 'y'
%     lb = [RHJCinitialxyz(1)-1000 RHJCinitialxyz(2)-1000 RHJCinitialxyz(3)-1000 50 100 200];
%     ub = [RHJCinitialxyz(1)+1000 RHJCinitialxyz(2)+1000 RHJCinitialxyz(3)+1000 200 400 500];
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ind = 1:nstarts
    %   Create vector of perturbations to initial guess
    pert = 2*half_cube_size*rand(1,3) - half_cube_size;
    
    if ind == 1
        x0 = xinitial;
    else
        % specify initial guess for solution
        x0(1) = xinitial(1) + pert(1);
        x0(2) = xinitial(2) + pert(2);
        x0(3) = xinitial(3) + pert(3);
    end
    
    % Optimize
    %[xopt,f] = fminsearch('ThightoHJC',x0,options,RTH1Pelvis,RTH2Pelvis,RTH3Pelvis);
    %[xopt,f]=fmincon('ThightoHJC',x0,[],[],[],[],lb,ub,[],options,RTH1Pelvis,RTH2Pelvis,RTH3Pelvis);
    %[xopt, f] = fminunc('ThightoHJC', x0, [], [], [], [], [], options, RTH1Pelvis, RTH2Pelvis, RTH3Pelvis);
    [xopt, f] = fminunc('ThightoHJC', x0, options, RTH1Pelvis, RTH2Pelvis, RTH3Pelvis)
    %disp(xopt);
    %   If this attempt yielded smaller value for objective function
    %   then update xbest, fbest, fl, and output
    if f < fbest
        xbest = xopt;
        fbest = f;
    end
end

%   Extract coordinates of optimal hip joint centre for 
rightOptimalHipX = xbest(1);
rightOptimalHipY = xbest(2);
rightOptimalHipZ = xbest(3);

optR1 = xbest(4);
optR2 = xbest(5);
optR3 = xbest(6);


%   Plot pelvis markers, thigh markers, anthropometric estimate of hip joint
%   centre, optimal hip joint centre, and spheres originating at optimal
%   hip centre with radii defined by the mean distance between optimal hip 
%   joint centre and thigh markers

dataOK = menu('View plotted data?', 'Yes', 'No');
if dataOK == 1;
hold off
scatter3(RTH1xPelvis,RTH1yPelvis,RTH1zPelvis);
hold on;
scatter3(RTH2xPelvis,RTH2yPelvis,RTH2zPelvis);
scatter3(RTH3xPelvis,RTH3yPelvis,RTH3zPelvis);
scatter3(SACRxPelvis,SACRyPelvis,SACRzPelvis,'r');
scatter3(LASIxPelvis,LASIyPelvis,LASIzPelvis,'r');
scatter3(RASIxPelvis,RASIyPelvis,RASIzPelvis,'r');
text(SACRxPelvis(1),SACRyPelvis(1),SACRzPelvis(1),'SACR');
text(LASIxPelvis(1),LASIyPelvis(1),LASIzPelvis(1),'LASI');
text(RASIxPelvis(1),RASIyPelvis(1),RASIzPelvis(1),'RAIS');
plot3([RASIxPelvis(1),LASIxPelvis(1),SACRxPelvis(1),RASIxPelvis(1)],...
[RASIyPelvis(1),LASIyPelvis(1),SACRyPelvis(1),RASIyPelvis(1)],...
[RASIzPelvis(1),LASIxPelvis(1),SACRzPelvis(1),RASIzPelvis(1)])
plot3(RHJCinitialxyz(1,1), RHJCinitialxyz(1,2), RHJCinitialxyz(1,3),'ro');
text(RHJCinitialxyz(1,1),RHJCinitialxyz(1,2),RHJCinitialxyz(1,3),'Initial');
plot3(rightOptimalHipX,rightOptimalHipY,rightOptimalHipZ,'go');
text(rightOptimalHipX,rightOptimalHipY,rightOptimalHipZ,'Optimal');
%title('Optimal Right HJC location. Red Markers - Hip,  Blue Markers - Thigh');
axis equal;
axis manual;
[x1,y1,z1]=sphere(12);
surface(x1*optR1+rightOptimalHipX,y1*optR1+rightOptimalHipY,z1*optR1+rightOptimalHipZ,'EdgeColor',[.6 .6 .6],'FaceColor','none');
[x2,y2,z2]=sphere(18);
surface(x2*optR2+rightOptimalHipX,y2*optR2+rightOptimalHipY,z2*optR2+rightOptimalHipZ,'EdgeColor',[.75 .75 .75],'FaceColor','none');
[x3,y3,z3]=sphere(25);
surface(x3*optR3+rightOptimalHipX,y3*optR3+rightOptimalHipY,z3*optR3+rightOptimalHipZ,'EdgeColor',[.9 .9 .9],'FaceColor','none');
 dataOK1 = menu('Is this data OK??', 'Yes', 'No');
 if dataOK1 == 2;
     error('Optimisation aborted by user');
 end
end



close;