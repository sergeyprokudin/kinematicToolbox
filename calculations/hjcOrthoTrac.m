function HJC = hjcOrthroTrac(varagin)
%UNTITLED Summary of this function goes here
   Detailed explanation goes here



% Uses HJC location of Orthotrak (Shea et al.1997 Gait and Posture 5,157)

prox_mkr1 = PelvisStruct(1).Data; %RASI
prox_mkr2 = PelvisStruct(2).Data; %LASI
prox_mkr3 = PelvisStruct(3).Data; %SACRUM

%Define the prox origin as the average of the prox markers
origin=(prox_mkr2+prox_mkr1+prox_mkr3 )/3;

% Calculate unit vectors of Pelvis origin relative to global
[e1Proximal,e2Proximal,e3Proximal]=segmentorientationV1V3(origin-prox_mkr3, prox_mkr2-prox_mkr1);

nFrames = size(prox_mkr1,1);

% Transform the prox and dist marker points into the pelvis coordinate system
for i=1:nFrames
    rotationmatrix=[e1Proximal(i,:);e2Proximal(i,:);e3Proximal(i,:)];
    originvector=origin(i,:)';
    RASI_Pelvis(i,:)=(rotationmatrix*(prox_mkr1(i,:)')-rotationmatrix*originvector)';
    LASI_Pelvis(i,:)=(rotationmatrix*(prox_mkr2(i,:)')-rotationmatrix*originvector)';
    SACRUM_Pelvis(i,:)=(rotationmatrix*(prox_mkr3(i,:)')-rotationmatrix*originvector)';
    
end

PelvisOrigin=(LASI_Pelvis+RASI_Pelvis)/2;
ASISDist=MarkerDistance(LASI_Pelvis,RASI_Pelvis);
InterASISDist=mean(ASISDist);
aa = InterASISDist/2;
MarkerDiameter=12;
mm = MarkerDiameter/2;


%HJC=(X,Y,Z)
Coord_LHJC = [-(0.21*InterASISDist)-mm (0.34*InterASISDist) -(0.32*InterASISDist)];
Coord_RHJC = [-(0.21*InterASISDist)-mm (-0.34*InterASISDist) -(0.32*InterASISDist)];

Reg_LHJC=[PelvisOrigin(:,1)+Coord_LHJC(:,1) PelvisOrigin(:,3)-Coord_LHJC(:,3) PelvisOrigin(:,2)+Coord_LHJC(:,2)];
Reg_RHJC=[PelvisOrigin(:,1)+Coord_RHJC(:,1) PelvisOrigin(:,3)-Coord_RHJC(:,3) PelvisOrigin(:,2)+Coord_RHJC(:,2)];


OrthotrakHipData(1,:)=mean(Reg_LHJC);
OrthotrakHipName(1,:)='Reg_LHJC';
OrthotrakHipData(2,:)=mean(Reg_RHJC);
OrthotrakHipName(2,:)='Reg_RHJC';

for yy=1:2
    [HipStruct]= Move_To_Global(PelvisStruct, OrthotrakHipData(yy,:)',OrthotrakHipName(yy,:));
    OrthotrackHipStruct(yy)=HipStruct;
end

end

