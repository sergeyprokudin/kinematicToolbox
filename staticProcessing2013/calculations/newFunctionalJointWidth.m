function [New_jointcenter_global,New_lateralmarker_global,New_medialmarker_global]=...
                newFunctionalJointWidth(parentMkr1,parentMkr2,parentMkr3,FC1,FC2,HA1,HA2); 
%UNTITLED4 Summary of this function goes here
% The projections  are done by computing the lateral and medial planes of the joint based on
%	the location of the laterally and medially placed markers.  The intersection of this plane
%	and the actual computed joint axis then determines the new and actual medial marker/lateral marker.
%	The center of the joint is equivalent to the center of these new points, and thus lies
%	on the actual computed joint axis.   


%%
parentMkr1 = mkrStruct(1).Data;
parentMkr2 = mkrStruct(2).Data;
parentMkr3 = mkrStruct(3).Data;

condyleMkr1 =FC1;
condyleMkr2 =FC2;

                        
%%            
% Define epicondylar axis 
        epicondylar_axis = (FC1-FC2);
% Define starting joint centre position
        joint_centre = (FC1+FC2)/2;
% Define helical axes vectors
    	helical_axis_vector = HA1-HA2;            
                        
%%                        
for i=1:nFrames
    	% Projects the joint center of the manually placed markers to the equivalent
    	%	joint center on the computed actual joint axis
    	t = (dot(epicondylar_axis(i,:),joint_centre(i,:))-dot(epicondylar_axis(i,:),HA1(i,:)))/dot(epicondylar_axis(i,:),helical_axis_vector(i,:));
        new_x = HA1(i,1)+helical_axis_vector(i,1)*t;
        new_y = HA1(i,2)+helical_axis_vector(i,2)*t;
        new_z = HA1(i,3)+helical_axis_vector(i,3)*t;
        New_jointcenter_global(i,:)=[new_x;new_y;new_z];
        
		% Projects the manually placed lateral marker to the computed actual joint axis
        t = (dot(epicondylar_axis(i,:),condyleMkr1(i,:))-dot(epicondylar_axis(i,:),HA1(i,:)))/dot(epicondylar_axis(i,:),helical_axis_vector(i,:));
        new_x = HA1(i,1)+helical_axis_vector(i,1)*t;
        new_y = HA1(i,2)+helical_axis_vector(i,2)*t;
        new_z = HA1(i,3)+helical_axis_vector(i,3)*t;
        New_lateralmarker_global(i,:)=[new_x;new_y;new_z];
       
		% Projects the manually placed medial marker to the computed actual joint axis
        t = (dot(epicondylar_axis(i,:),condyleMkr2(i,:))-dot(epicondylar_axis(i,:),HA1(i,:)))/dot(epicondylar_axis(i,:),helical_axis_vector(i,:));
        new_x = HA1(i,1)+helical_axis_vector(i,1)*t;
        new_y = HA1(i,2)+helical_axis_vector(i,2)*t;
        new_z = HA1(i,3)+helical_axis_vector(i,3)*t;
        New_medialmarker_global(i,:)=[new_x;new_y;new_z];
       
end        
         
%%
%Put joint center and lateral/medial markers in parent coordinates
    parentcoord_jointcenter =   rotationmatrix*(New_jointcenter_global(1,:)' - originProx(1,:)');
    parentcoord_lateralmarker = rotationmatrix*(New_lateralmarker_global(1,:)' - originProx(1,:)');
    parentcoord_medialmarker =  rotationmatrix*(New_medialmarker_global(1,:)' - originProx(1,:)');
    
    
            

end

