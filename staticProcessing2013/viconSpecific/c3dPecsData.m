function [mkrStruct,trialName, dataPath,analogRate,sampleRate,First,Last] =  c3dPecsData(hTrial)
%Gets all the marker data and event times from the c3d using pecs
%Author:James Dunne, Thor Besier. 
%Last Update: April 2012 


%% Trial Description
trialName = invoke( hTrial, 'ReferenceName');
dataPath = invoke( hTrial, 'DataPath');
analogRate = invoke( hTrial, 'AnalogBaseRate');


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

%% Extract Marker Time 
        %Determine the First and last valid frame for each marker..
        %This will cut data into a size where everymarker is present
 
nMarkers = length(MarkerNames);
First=[];
Last=[];

        
for yy=1:nMarkers
mkr_name = [char(MarkerNames(yy))];
i1 = invoke( hTrial, 'FindTrajectoryIndex', mkr_name, 0 );
hTraj1 = invoke( hTrial, 'Trajectory', i1 );
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
         
%% Place Marker Data Structure based on first and Last time points
nFrames = Last-First+1;
for i = 1:nMarkers
    mkrName = MarkerNames{i};
    index = invoke( hTrial, 'FindTrajectoryIndex', mkr_name, 0 );
    hTraj = invoke( hTrial, 'Trajectory', index );
    data = invoke( hTraj, 'GetPoints', First, Last );%Data associated with a Marker
    %Place data into a structure (MarkerStruct) 
    eval(['mkrStruct.' char(mkrName) '= data;']);
end
        
end

