%   PECS front end code to enable calculation of
%   mean helical elbow joint flexion/extension and pronation/supination axes via Vicon
%   Workstation Pipeline. The outputs are written back to the subject model parameter file.
%
%   Required:
%
%      Matlab Components
%           Matlab signal processing toolbox
%           Matlab optimisation toolbox
%
%      Main Custom functions
%           meanhelicalkneeaxis.m
%           screw.m
%           soder.m
%           segmentorientation2.m
%           rad2deg.m
%           matfiltfilt.m
%           distance.m
%           Thigh2HJC.m
%
%
%   Developed in:           Matlab R14
%   Developed by:           Yanxin Zhang
%   Contributions from:     Peter Mills, David Lloyd, Thor Besier, Rod Barrett,
%                           Ton Van Den Bogert, Mark Soderqvist, Kane
%                           Middleton
%
%   Version:        1.00
%   Last modified:  12.04.2010
%
%
%%  Clear matlab memory, clear command window, close all figures
%clear
close all
%clc
%%   Create PECS server
hServer = actxserver( 'PECS.Document' );
invoke( hServer, 'Refresh' );


%%   Get required handles
hTrial = get(hServer, 'Trial');
hEventStore = get(hTrial, 'EventStore');
hSubject = get(hTrial, 'Subject',0);
hEclipseNode = get(hTrial, 'EclipseNode');
dataPath = char(invoke(hEclipseNode, 'DataPath'));
subjectName = char(invoke(hSubject, 'Name'));


%%   Detemine number of events in trial
EventCount = double(invoke(hEventStore, 'EventCount'));
VideoRate = double(invoke(hTrial,'VideoRate'));


%   Get event times, types and sides for all events
for i = 1:EventCount
    hEvent = get(hEventStore, 'Event', i-1);
    eventTypes(i) = double(invoke(hEvent, 'IconID'));
    eventTimes(i) = double(invoke(hEvent, 'Time'))* VideoRate;
    eventSideSection = invoke(hEvent, 'Context');
    eventSide = invoke(eventSideSection, 'Label');
    eventSides(i) = eventSide(1);
end


%   Rearrange general events to ensure they are in ascending order wrt time
[eventTimes, newOrder] = sort(eventTimes);
for j = 1:length(eventTypes);
    newEventTypes(j) = eventTypes(newOrder(j));
    newEventSides(j) = eventSides(newOrder(j));
end

eventTypes = newEventTypes;
eventTypes2 = genvarname(num2str(eventTypes));
eventSides = newEventSides;
eventSideType = [eventSides; eventTypes2(2:end);]';

%%  Determine optimisation routine(s) to run for this trial based on event
%   markers. Initial frame event marker(s) define which optimisation
%   routines to run.
%
%   eventSides: L = Left, Right = Right, G = General
%   eventTypes: 0 = Elbow pronation/supination (general event), 1 = Elbow
%   flexion/extension (up arrow)
%   
optimCode(1,:) = [eventSides(1), num2str(eventTypes(1))];
if eventTimes(2) == eventTimes(1)
    optimCode(2,:) = [eventSides(2), num2str(eventTypes(2))];
    if eventTimes(3) == eventTimes(1)
        optimCode(3,:) =[eventSides(3), num2str(eventTypes(3))];
        if eventTimes(4) == eventTimes(1)
            optimCode(4,:) = [eventSides(4), num2str(eventTypes(4))];
                end
            end
        end
  


%%  Determine 1st and last frames over which optimisation routines are to
%   be run
%   LE F/E
match = regexp(cellstr(optimCode),'L1');
if max(cell2mat(match)) == 1;
    LEJA = 1;
    index = regexp(cellstr(eventSideType), 'L1');
    increment = 1;
    for i = 1:EventCount%6
        if index{i} == 1;
            indexLEJA(increment) = (i);
            increment = increment + 1;
        end
    end
    startLEJA = eventTimes(indexLEJA(2));
    endLEJA = eventTimes(indexLEJA(3));
else
    LEJA = 0;
end

%   RE F/E
match = regexp(cellstr(optimCode),'R1');
if max(cell2mat(match)) == 1;
    REJA = 1;
    index = regexp(cellstr(eventSideType), 'R1');
    increment = 1;
    for i = 1:EventCount%6
        if index{i} == 1;
            indexREJA(increment) = (i);
            increment = increment + 1;
        end
    end
    startREJA = eventTimes(indexREJA(2));
    endREJA = eventTimes(indexREJA(3));
else
    REJA = 0;
end

%%
%   LE S/A
match = regexp(cellstr(optimCode),'L0');
if max(cell2mat(match)) == 1;
    LEJA = 1;
    index = regexp(cellstr(eventSideType), 'L0');
    increment = 1;
    for i = 1:EventCount%6
        if index{i} == 1;
            indexLEJA(increment) = (i);
            increment = increment + 1;
        end
    end
    startLEJA = eventTimes(indexLEJA(2));
    endLEJA = eventTimes(indexLEJA(3));
else
    LEJA = 0;
end

%   RE S/A
match = regexp(cellstr(optimCode),'R0');
if max(cell2mat(match)) == 1;
    REJA = 1;
    index = regexp(cellstr(eventSideType), 'R0');
    increment = 1;
    for i = 1:EventCount%6
        if index{i} == 1;
            indexREJA(increment) = (i);
            increment = increment + 1;
        end
    end
    startREJA = eventTimes(indexREJA(2));
    endREJA = eventTimes(indexREJA(3));
else
    REJA = 0;
end

%%   Load model parameter file
cd(dataPath)
[variableName, equalSign, value]...
    = textread([subjectName '.mp'], '%s %s %s');


%   Check model parameter file to determine whether calculation of mean
%   helical elbow F/E axis is required
if LEJA == 1 || REJA == 1;
    helicalElbowIndex = strmatch('$HelicalElbow', variableName);
 %  paramToOptimiseEJA = value(helicalElbowIndex);
    paramToOptimiseEJA = strcmp('1', value(helicalElbowIndex));
else
    paramToOptimiseEJA = 0;
end


%   Check model parameter file to determine whether calculation of mean
%   helical Elbow S/P axis is required
if LEJA == 1 || REJA == 1;
    helicalElbowIndex = strmatch('$HelicalElbow', variableName);
    paramToOptimiseEJA = strcmp('1', value(helicalElbowIndex));
else
    paramToOptimiseEJA = 0;
end


% Run specified optimisation routine(s)
%%   LEJA
if LEJA == 1 && paramToOptimiseEJA == 1
    %   Define trajectory indexes for the required trajectories
    TrajectoryCount = double(invoke(hTrial, 'TrajectoryCount'));
    TrajectoryIndex_iLUA1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'iLUA1', 0));
    TrajectoryIndex_iLUA2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'iLUA2', 0));
    TrajectoryIndex_iLUA3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'iLUA3', 0));
    TrajectoryIndex_LFA1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA1', 0));
    TrajectoryIndex_LFA2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA2', 0));
    TrajectoryIndex_LFA3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA3', 0));

    %   Get handles to all required trajectories
    hTrajectory_iLUA1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_iLUA1));
    hTrajectory_iLUA2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_iLUA2));
    hTrajectory_iLUA3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_iLUA3));
    hTrajectory_LFA1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LFA1));
    hTrajectory_LFA2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LFA2));
    hTrajectory_LFA3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LFA3));

    %   Get trajectories required for optimisation
    iLUA1 = (invoke(hTrajectory_iLUA1, 'GetPoints', startLEJA, endLEJA))';
    iLUA2 = (invoke(hTrajectory_iLUA2, 'GetPoints', startLEJA, endLEJA))';
    iLUA3 = (invoke(hTrajectory_iLUA3, 'GetPoints', startLEJA, endLEJA))';
    LFA1 = (invoke(hTrajectory_LFA1, 'GetPoints', startLEJA, endLEJA))';
    LFA2 = (invoke(hTrajectory_LFA2, 'GetPoints', startLEJA, endLEJA))';
    LFA3 = (invoke(hTrajectory_LFA3, 'GetPoints', startLEJA, endLEJA))';

    %   Release handles to required trajectories
    release(hTrajectory_iLUA1);
    release(hTrajectory_iLUA2);
    release(hTrajectory_iLUA3);
    release(hTrajectory_LFA1);
    release(hTrajectory_LFA2);
    release(hTrajectory_LFA3);

    iLUA = [iLUA1, iLUA2, iLUA3];
    LFA = [LFA1, LFA2, LFA3];


    PECS_lefthelicalelbow;

    %   Update values obtained from mp file
    for i = 1:length(variableName)
        if strcmp(char(variableName(i)), '$LEnHA1');
            a=sprintf('{%f,%f,%f}',LEHA1(1),LEHA1(2),LEHA1(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s);
        elseif strcmp(char(variableName(i)), '$LEnHA2');
            a=sprintf('{%f,%f,%f}',LEHA2(1),LEHA2(2),LEHA2(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s);
      
        end
    end
end


%%  REJA
if REJA == 1 && paramToOptimiseEJA == 1
    %   Define trajectory indexes for the required trajectories
    TrajectoryCount = double(invoke(hTrial, 'TrajectoryCount'));
    TrajectoryIndex_iRUA1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'iRUA1', 0));
    TrajectoryIndex_iRUA2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'iRUA2', 0));
    TrajectoryIndex_iRUA3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'iRUA3', 0));
    TrajectoryIndex_RFA1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA1', 0));
    TrajectoryIndex_RFA2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA2', 0));
    TrajectoryIndex_RFA3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA3', 0));

    %   Get handles to all required trajectories
    hTrajectory_iRUA1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_iRUA1));
    hTrajectory_iRUA2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_iRUA2));
    hTrajectory_iRUA3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_iRUA3));
    hTrajectory_RFA1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RFA1));
    hTrajectory_RFA2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RFA2));
    hTrajectory_RFA3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RFA3));

    %   Get trajectories required for optimisation
    iRUA1 = (invoke(hTrajectory_iRUA1, 'GetPoints', startREJA, endREJA))';
    iRUA2 = (invoke(hTrajectory_iRUA2, 'GetPoints', startREJA, endREJA))';
    iRUA3 = (invoke(hTrajectory_iRUA3, 'GetPoints', startREJA, endREJA))';
    RFA1 = (invoke(hTrajectory_RFA1, 'GetPoints', startREJA, endREJA))';
    RFA2 = (invoke(hTrajectory_RFA2, 'GetPoints', startREJA, endREJA))';
    RFA3 = (invoke(hTrajectory_RFA3, 'GetPoints', startREJA, endREJA))';

    %   Release handles to required trajectories
    release(hTrajectory_iRUA1);
    release(hTrajectory_iRUA2);
    release(hTrajectory_iRUA3);
    release(hTrajectory_RFA1);
    release(hTrajectory_RFA2);
    release(hTrajectory_RFA3);

    iRUA = [iRUA1, iRUA2, iRUA3];
    RFA = [RFA1, RFA2, RFA3];

    %   Calculate mean helical axis
    PECS_righthelicalelbow;
    
    faiouyas=REHA1;
    
    %   Update values obtained from mp file
    for i = 1:length(variableName)
        if strcmp(char(variableName(i)),'$REnHA1');
            a=sprintf('{%f,%f,%f}',REHA1(1),REHA1(2),REHA1(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s);
        elseif strcmp(char(variableName(i)),'$REnHA2');
            a=sprintf('{%f,%f,%f}',REHA2(1),REHA2(2),REHA2(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s);
        end
    end
end


%%   Overwrite existing model parameter file
fid = fopen([subjectName '.mp'], 'w');
for i = 1:length(variableName);
    fprintf(fid,'%s %s %s\r\n', char(variableName(i))',char(equalSign(i))', char(value(i)'));
end
fclose(fid);

%   Enable user to view updated parameter file
toViewParam = menu('Optimisation complete',...
    'Exit and view the parameter file',...
    'Exit without viewing parameter file');
if toViewParam == 1;
    dos([subjectName '.mp'])
 %   uiwait(msgbox(' ','Continue          ','modal'));
end

%%   Release PECS server and trial and quit matlab
release(hTrial);
release(hServer);
release(hEventStore);
release(hSubject);
release(hEclipseNode);
close all;
