function [segmentsys] = segmentsystem(P1,P2,P3,P4,order)
% Defines the othagonal anatomical corindate system of a segment
% [segmentsys] = segmentsystem(AX1,AX2,JC1,JC2)
%P1    =   Medial Axis Marker
%P2    =   Lateral Axis Marker
%P3    =   Superior Joint center location (ie HJC)
%P4    =   Inferior Joint center location (ie KJC)
%
%  [thigh] = segmentsystem(RLFC,RMFC,RHJC,RKJC,'zyx');
%  [pelvis] = segmentsystem(RASI,LASI,MidPEL,SACR,'zxy');

if  strcmp(order,'zxy')
%   Defines the local Z axis (flexion extension)
        Zaxis=unit(P1-P2); 
%   Defines the local Y axis along the segment (rotation)
        Yaxis=unit(P3-P4); 
%   Defines the local X axis othorgonally (abduction)
        Xaxis=cross(Yaxis,Zaxis); 
        Xaxis=unit(Xaxis);
%   Defines the local z axis as othorgonal(flexion extension)
        Zaxis=cross(Xaxis,Yaxis);
        Zaxis=unit(Zaxis);
%   Save into a single variable
    segmentsys=[Zaxis Yaxis Xaxis ];

elseif strcmp(order,'zyx')
  
%   Defines the local Z axis (flexion extension)
        Zaxis=unit(P1-P2); 
%   Defines the local X axis along the segment (rotation)
        Xaxis=unit(P3-P4); 
%   Defines the local Y axis othorgonally (roll)
        Yaxis=cross(Zaxis,Xaxis); 
        Yaxis=unit(Yaxis);
%   Defines the local X axis as othorgonal(flexion extension)
        Xaxis=cross(Yaxis,Zaxis);
        Xaxis=unit(Xaxis);
%   Save into a single variable
    segmentsys=[Zaxis Yaxis Xaxis ];    
    
end