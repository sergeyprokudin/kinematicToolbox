function [New_jointcenter_global,New_lateralmarker_global,New_medialmarker_global]=...
                CreateHelicalJoint(ParentStruct,CondyleData,HA1_mk1,HA2_mk2)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


%%
prox_mkr1 = ParentStruct(1).Data;
prox_mkr2 = ParentStruct(2).Data;
prox_mkr3 = ParentStruct(3).Data;

Condlye_mkr1=CondyleData(1).Data;
Condlye_mkr2 =CondyleData(2).Data;

[m n]=size(Condlye_mkr1);
if m<n;Condlye_mkr1=Condlye_mkr1'; Condlye_mkr2=Condlye_mkr2';end;


                        
                                    
%%     
% The following e1, e2,e3 is the samecalculation as in the findjointaxes code.
    originProx=(prox_mkr1+prox_mkr2+prox_mkr3)/3; 
    [e1Prox,e2Prox,e3Prox]=segmentorientationV2V1(prox_mkr1-prox_mkr3,prox_mkr2-originProx);
	nFrames = size(prox_mkr3,1);
    for i=1:nFrames
    	rotationmatrix=[e1Prox(i,:);e2Prox(i,:);e3Prox(i,:)];
        rotationmatrixinv=inv(rotationmatrix);
        LHA1(i,:)= rotationmatrixinv*HA1_mk1 + originProx(i,:)';
        LHA2(i,:)= rotationmatrixinv*HA2_mk2 + originProx(i,:)';
	end   
                        
%%            
% Define epicondylar axis 
        epicondylar_axis = (Condlye_mkr1-Condlye_mkr2);
% Define starting joint centre position
        joint_centre = (Condlye_mkr1+Condlye_mkr2)/2;
% Define helical axes vectors
    	helical_axis_vector = LHA1-LHA2;            
                        
%%                        
for i=1:nFrames
    	% Projects the joint center of the manually placed markers to the equivalent
    	%	joint center on the computed actual joint axis
    	t = (dot(epicondylar_axis(i,:),joint_centre(i,:))-dot(epicondylar_axis(i,:),LHA1(i,:)))/dot(epicondylar_axis(i,:),helical_axis_vector(i,:));
        new_x = LHA1(i,1)+helical_axis_vector(i,1)*t;
        new_y = LHA1(i,2)+helical_axis_vector(i,2)*t;
        new_z = LHA1(i,3)+helical_axis_vector(i,3)*t;
        New_jointcenter_global(i,:)=[new_x;new_y;new_z];
        
		% Projects the manually placed lateral marker to the computed actual joint axis
        t = (dot(epicondylar_axis(i,:),Condlye_mkr1(i,:))-dot(epicondylar_axis(i,:),LHA1(i,:)))/dot(epicondylar_axis(i,:),helical_axis_vector(i,:));
        new_x = LHA1(i,1)+helical_axis_vector(i,1)*t;
        new_y = LHA1(i,2)+helical_axis_vector(i,2)*t;
        new_z = LHA1(i,3)+helical_axis_vector(i,3)*t;
        New_lateralmarker_global(i,:)=[new_x;new_y;new_z];
       
		% Projects the manually placed medial marker to the computed actual joint axis
        t = (dot(epicondylar_axis(i,:),Condlye_mkr2(i,:))-dot(epicondylar_axis(i,:),LHA1(i,:)))/dot(epicondylar_axis(i,:),helical_axis_vector(i,:));
        new_x = LHA1(i,1)+helical_axis_vector(i,1)*t;
        new_y = LHA1(i,2)+helical_axis_vector(i,2)*t;
        new_z = LHA1(i,3)+helical_axis_vector(i,3)*t;
        New_medialmarker_global(i,:)=[new_x;new_y;new_z];
       
end        
         
%%
%Put joint center and lateral/medial markers in parent coordinates
    parentcoord_jointcenter = rotationmatrix*(New_jointcenter_global(1,:)' - originProx(1,:)');
    parentcoord_lateralmarker = rotationmatrix*(New_lateralmarker_global(1,:)' - originProx(1,:)');
    parentcoord_medialmarker = rotationmatrix*(New_medialmarker_global(1,:)' - originProx(1,:)');
    
    
%(*) The projections above are done by computing the lateral and medial planes of the joint based on
%	the location of the laterally and medially placed markers.  The intersection of this plane
%	and the actual computed joint axis then determines the new and actual medial marker/lateral marker.
%	The center of the joint is equivalent to the center of these new points, and thus lies
%	on the actual computed joint axis.               

end

