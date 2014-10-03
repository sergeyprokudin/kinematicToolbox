function [summed_deviation]=ThightoHJC(x,TH1Pelvis,TH2Pelvis,TH3Pelvis)

% R1, R2 and R3 are the radii of the three projected sphere's around the hip joint centre for each marker. 
% This function calculates the mean squared difference between each thigh marker and the estimated 
% sphere about the hip joint. This function is minimised by the optimisation routine in findlefthipcentre.m and findrighthipcentre.m.

HJCxyz=x(1:3);

%R1=x(4);
%R2=x(5);
%R3=x(6);

R1=mean(sqrt((TH1Pelvis(1,1)-x(1)).^2+(TH1Pelvis(1,2)-x(2)).^2+(TH1Pelvis(1,3)-x(3)).^2));
R2=mean(sqrt((TH2Pelvis(1,1)-x(1)).^2+(TH2Pelvis(1,2)-x(2)).^2+(TH2Pelvis(1,3)-x(3)).^2));
R3=mean(sqrt((TH3Pelvis(1,1)-x(1)).^2+(TH3Pelvis(1,2)-x(2)).^2+(TH3Pelvis(1,3)-x(3)).^2));

for i=1:length(TH1Pelvis)
    HJCPelvis(i,:) = HJCxyz;
end

dist1 = distance(TH1Pelvis,HJCPelvis)-R1;
dist1n=sum(abs(dist1));

dist2 = distance(TH2Pelvis,HJCPelvis)-R2;
dist2n=sum(abs(dist2));

dist3 = distance(TH3Pelvis,HJCPelvis)-R3;
dist3n=sum(abs(dist3));

summed_deviation = dist1n+dist2n+dist3n;