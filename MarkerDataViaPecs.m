function [MarkerStruct,trial_name, dat_path,analog_rate,sampleRate,First,Last] =  MarkerDataViaPecs(hTrial)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%% Trial Description
trial_name = invoke( hTrial, 'ReferenceName');
dat_path = invoke( hTrial, 'DataPath');
analog_rate = invoke( hTrial, 'AnalogBaseRate');



%% Subject Details
subject_count = invoke( hTrial, 'SubjectCount');
if subject_count > 0
    hSubject = invoke( hTrial, 'Subject',0);
    prefix=invoke( hSubject, 'LabelPrefix');
    mkr_set_used = invoke( hSubject, 'MarkerSetName');
else
    prefix = [];
end


%% Get the Marker Names  
nTrajectories = invoke( hTrial,'TrajectoryCount');
  for k=0:(nTrajectories-1)  
         hTraj1 = invoke( hTrial, 'Trajectory', k );
         LabelName= invoke(hTraj1,'Label');
         MarkerNames(k+1)={LabelName};
  end    

  
%% Extract MarkerNames and delete non-labelled Markers
  index=[];
for ss=1:length(MarkerNames)
      if strfind(char(MarkerNames(ss)),'*')>0
              index=[index ss];    
	  end
end
MarkerNames(index)=[];

%% Get Sample Rate
        mkr1_name = char(MarkerNames(1));
        i1 = invoke( hTrial, 'FindTrajectoryIndex', mkr1_name, 0 );
        hTraj1 = invoke( hTrial, 'Trajectory', i1 );
        sampleRate = invoke( hTraj1, 'sampleRate' );

%% Extract Marker Time vector
        %Determine the First and last valid frame for each marker..
        %This will cut data into a size where everymarker is present
 
        nMarkers = length(MarkerNames);
        First=[];
        Last=[];

        
            for yy=1:nMarkers
                mkr_name = [char(MarkerNames(yy))];
                i1 = invoke( hTrial, 'FindTrajectoryIndex', mkr_name, 0 );
                hTraj1 = invoke( hTrial, 'Trajectory', i1 );
                sampleRate = invoke( hTraj1, 'sampleRate' );
                
                FirstMarkerFrame = invoke( hTraj1, 'FirstValidFieldNum' );
                LastMarkerFrame = invoke( hTraj1, 'LastValidFieldNum' );

               if yy==1    
                     First=FirstMarkerFrame;Last=LastMarkerFrame;
               end
                
               if   FirstMarkerFrame>First
                          First=FirstMarkerFrame;
               end

               if LastMarkerFrame<Last
                     Last=LastMarkerFrame;
               end
                
            end
                First=double(First);
                Last=double(Last);
%% Event time used?

    % [ EventTime  ] = getevents(hTrial,sampleRate);
    % if isempty(EventTime)==0
    %     [m n]=size(EventTime);
    %     if n>1
    %         First=EventTime(1);
    %         Last=EventTime(2);
    %     end
    % end            
            
            
    %% Import Marker Data into Time vector
	%Import all the Markers into a Structure
        nFrames = Last-First+1;
        for i = 1:nMarkers
            mkr_name = MarkerNames{i};
            index = invoke( hTrial, 'FindTrajectoryIndex', mkr_name, 0 );
            hTraj = invoke( hTrial, 'Trajectory', index );
            data = invoke( hTraj, 'GetPoints', First, Last );%Data associated with a Marker

         %Place data into a structure (MarkerStruct) 
             MarkerStruct(i) = struct('Name', {char(MarkerNames(i))},'Data', {data'});
        end
        
end

