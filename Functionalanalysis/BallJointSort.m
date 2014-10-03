function [JointAxes,NewAxisLabels] = BallJointSort(Filt_MarkerStruct,joint,trial_type,EventTime )
%This is a sorting function which places the right data (LASI, RASI , LPSI
% RPSI) into the correct functions so that they can be past onto the ball 
% joint calculation function successfully. 
% Success of this function depends on the order you have placed the markers in 
% 'LASI' 'RASI' 'LPSI' 'RPSI'.
%Author: James Dunne <dunne.jimmy@gmail.com>
%Created: Feburary 2010
%Latest update: March 2012

						
%% For Hip, you need to creat a Sacrum Marker
        % Markers stored in 'Filt_MarkerStruct' are assumed to have the
        % order {'RASI'} {'LASI'} {'RPSI'} {'LPSI'} {'LTH1'} {'LTH2'}
        % {'LTH3'} {'RTH1'} {'RTH2'} {'RTH3'}

        kk=length(Filt_MarkerStruct);
        Sacrum=(Filt_MarkerStruct(3).Data+Filt_MarkerStruct(4).Data)/2;
        Filt_MarkerStruct(kk+1)=struct('Name', {'Sacrum'},'Data', {Sacrum});%Append Sacrum to Stucture
        Cells=[1 2 (kk+1)];                                 %designate the RASI, LASI and Sacrum cells
							
	
%% Define the three proximal markers                    
        prox_mkr_trajectories = Filt_MarkerStruct(Cells);   % The three Right proximal Markers 
% if Event time is empty then just split the trial in half to get the best
% approximation


if isempty(EventTime)==1
    EventTime=round(length(Filt_MarkerStruct(5).Data)/2);
end

%% Do the calculation for the left leg first       
            % Define the three Distal markers
        dist_mkr_trajectories = Filt_MarkerStruct(5:7);     % The three Right Distal Markers
		    % Create the Variable name which indicates Left
        JointType=['L' char(trial_type)];

        
        if std(dist_mkr_trajectories(1).Data(1:EventTime,3))> std(dist_mkr_trajectories(1).Data(EventTime:end,3))
                dist_mkr_trajectories(1).Data(EventTime:end,:)=[];
                dist_mkr_trajectories(2).Data(EventTime:end,:)=[];
                dist_mkr_trajectories(3).Data(EventTime:end,:)=[];
                prox_mkr_trajectories(1).Data(EventTime:end,:)=[];
                prox_mkr_trajectories(2).Data(EventTime:end,:)=[];
                prox_mkr_trajectories(3).Data(EventTime:end,:)=[];
                
        else
               dist_mkr_trajectories(1).Data(1:EventTime,:)=[];
               dist_mkr_trajectories(2).Data(1:EventTime,:)=[];
               dist_mkr_trajectories(3).Data(1:EventTime,:)=[];
               prox_mkr_trajectories(1).Data(1:EventTime,:)=[];
               prox_mkr_trajectories(2).Data(1:EventTime,:)=[];
               prox_mkr_trajectories(3).Data(1:EventTime,:)=[];
        end
        
            % Run the ball joint calculation for the left hip
        [LeftJointAxis] =findballjointcentre(prox_mkr_trajectories,dist_mkr_trajectories);
		NewAxisLabels={['L' char(joint)]};

%% Do the calculation for the Right leg        
							
        JointType=['R' char(trial_type)];                   % Create the Variable name which indicates Right
        prox_mkr_trajectories = Filt_MarkerStruct(Cells);   % The three Right proximal Markers 
        dist_mkr_trajectories = Filt_MarkerStruct(8:10);    % The three Left Distal Markers
        
          if std(dist_mkr_trajectories(1).Data(1:EventTime,3))> std(dist_mkr_trajectories(1).Data(EventTime:end,3))
                dist_mkr_trajectories(1).Data(EventTime:end,:)=[];
                dist_mkr_trajectories(2).Data(EventTime:end,:)=[];
                dist_mkr_trajectories(3).Data(EventTime:end,:)=[];
                prox_mkr_trajectories(1).Data(EventTime:end,:)=[];
                prox_mkr_trajectories(2).Data(EventTime:end,:)=[];
                prox_mkr_trajectories(3).Data(EventTime:end,:)=[];
        else
               dist_mkr_trajectories(1).Data(1:EventTime,:)=[];
               dist_mkr_trajectories(2).Data(1:EventTime,:)=[];
               dist_mkr_trajectories(3).Data(1:EventTime,:)=[];
               prox_mkr_trajectories(1).Data(1:EventTime,:)=[];
               prox_mkr_trajectories(2).Data(1:EventTime,:)=[];
               prox_mkr_trajectories(3).Data(1:EventTime,:)=[];
        end
        
        [RightJointAxis] =findballjointcentre(prox_mkr_trajectories,dist_mkr_trajectories);
        JointAxes=[LeftJointAxis RightJointAxis];
        NewAxisLabels([2])={['R' char(joint)]};
							 
				 

                 
 end
 
                 


























