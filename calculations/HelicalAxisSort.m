function [JointAxes,NewAxisLabels] = HelicalAxisSort(Filt_MarkerStruct,trial_type,sampleRate)
% This code sorts Data Before passing them to helicalaxis.m  
%The successful completion of analysis depends on the order in which you have listed the Markernames
%Assumes Left Proximal Markers,left distal, right proximal and right distal.
%ie {'LTH1'} {'LTH2'} {'LTH3'} {'LTB1'} {'LTB2'} {'LTB3'} {'RTH1'} {'RTH2'} {'RTH3'} {'RTB1'}...
%              {'RTB2'} {'RTB3'}
%Author: James Dunne <dunne.jimmy@gmail.com>
%Create: Feburary 2010
%Last Update: May 2011


%% Left side 
%     define Proximals
prox_mkr_trajectories = Filt_MarkerStruct(1:3);% The three Right proximal Markers 
%     define Distals
dist_mkr_trajectories = Filt_MarkerStruct(4:6);% The three Right Distal Markers

%     Conduct Helical axis calculation
[LeftJointAxis] = UWAHelicaltest2011(prox_mkr_trajectories, dist_mkr_trajectories, sampleRate);
% [LeftJointAxis] = findjointaxes(prox_mkr_trajectories,dist_mkr_trajectories);

%     Naming & storage
NewAxisLabels={['LL' char(trial_type)] ['LM' char(trial_type)]};

%% Right side 
%     define Proximals
prox_mkr_trajectories = Filt_MarkerStruct(7:9);% The three Right proximal Markers 
%     define Distals
dist_mkr_trajectories = Filt_MarkerStruct(10:12);% The three Right Distal Markers

%     Conduct Helical axis calculation
[RightJointAxis] =UWAHelicaltest2011(prox_mkr_trajectories, dist_mkr_trajectories, sampleRate);
% [RightJointAxis] =findjointaxes(prox_mkr_trajectories,dist_mkr_trajectories);

% RightJointAxis=helical_axes;
%     Naming & storage
JointAxes=[LeftJointAxis RightJointAxis];
NewAxisLabels([3 4])={['RL' char(trial_type)] ['RM' char(trial_type)]};
                        
end




