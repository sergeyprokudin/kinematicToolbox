function [NewJointCenterStruct]= Move_To_Global(ProxStruct, Coordinate,Coordinatename)


                prox_mkr1 = ProxStruct(1).Data;
                prox_mkr2 = ProxStruct(2).Data;
                prox_mkr3 = ProxStruct(3).Data;
                virtualcoordinate=Coordinate;


origin=(prox_mkr2+prox_mkr1+prox_mkr3)/3;
[e1Proximal,e2Proximal,e3Proximal]=segmentorientationV1V3(origin-prox_mkr3,prox_mkr2-prox_mkr1);
nFrames = size(prox_mkr3,1);
[m NumberofVirtualCoordinates]=size(virtualcoordinate);


    for i=1:nFrames
        rotationmatrix=[e1Proximal(i,:);e2Proximal(i,:);e3Proximal(i,:)];
        rotationmatrix=inv(rotationmatrix);
        JC(i,:)= rotationmatrix*virtualcoordinate + origin(i,:)';
    end


NewJointCenterStruct=struct('Name',{char(Coordinatename)},'Data',{JC});




end





