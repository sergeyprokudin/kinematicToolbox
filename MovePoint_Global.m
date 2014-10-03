function [globalcoordinate]= MovePoint_Global(ProxStruct, Coordinate)
% Move a point coordinate from a technical based coordinate system back into
% a global based coordinate system 
% ProxStruct        Stucture of three markers which represent a technical coordinate sytem
% Coordinate        x,y,x coordinates in a single coloumn 
%%
                if isstruct(ProxStruct)
                    prox_mkr1=ProxStruct(1).Data;
                    prox_mkr2=ProxStruct(2).Data;
                    prox_mkr3=ProxStruct(3).Data;
                else
                    prox_mkr1=ProxStruct(:,1:3);
                    prox_mkr2=ProxStruct(:,4:6);
                    prox_mkr3=ProxStruct(:,7:9);
                end
                
%                 [m1 n1]=size(Coordinate);
%                 [m2 n2]=size(prox_mkr1);
%                 
%                 if m1<m2
%                      virtualcoordinate=repmat(Coordinate,m2,1)';
%                 else
%                     virtualcoordinate=Coordinate';
%                 end
                [m n]=size(Coordinate);
                if m<n
                    virtualcoordinate=Coordinate';
                else
                     virtualcoordinate=Coordinate;
                end
                

                    
%%

origin=(prox_mkr2+prox_mkr1+prox_mkr3)/3;
%[e1Proximal,e2Proximal,e3Proximal]=segmentorientationV1V3(origin-prox_mkr3,prox_mkr2-prox_mkr1);

[e1Proximal,e2Proximal,e3Proximal]=segmentorientationV2V1(prox_mkr1-prox_mkr3,prox_mkr2-origin);


nFrames = size(prox_mkr3,1);
[m NumberofVirtualCoordinates]=size(virtualcoordinate);


    for i=1:nFrames
        rotationmatrix=[e1Proximal(i,:);e2Proximal(i,:);e3Proximal(i,:)];
        rotationmatrix=inv(rotationmatrix);
        globalcoordinate(i,:)= rotationmatrix*virtualcoordinate + origin(i,:)';
    end




end




