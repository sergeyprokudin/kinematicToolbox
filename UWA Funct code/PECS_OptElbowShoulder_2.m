%   PECS front end code to enable calculation of optimal shoulder joint centres
%   and mean melical elbow joint helical flexion/extension and pronation/supination axes via Vicon
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
%                           Ton Van Den Bogert, Mark Soderqvist
%
%   Version:        1.00
%   Last modified:  12.11.2007
%
%
%%  Clear matlab memory, clear command window, close all figures
%clear
close all


global  hServer;
global  hTrial;
global  hProcessor;
global  hParamStore;
global  hEvStore;

hServer = actxserver( 'PECS.Document' );
invoke( hServer, 'Refresh' );

hProcessor = get(hServer, 'Processor' );
hParamStore = get(hTrial, 'ParameterStore' );
hEvStore = get(hTrial, 'EventStore' );

%%   Get required handles
hTrial = get(hServer, 'Trial');
hEventStore = get(hTrial, 'EventStore');
hSubject = get(hTrial, 'Subject');
hEclipseNode = get(hTrial, 'EclipseNode');

dat_path = invoke( hTrial, 'DataPath');
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
%   eventTypes: 0 = Elobw pronation/supination (general event), 1 = SJC (diamond)
%               2 = Elobw flexion/extension (up arrow)
optimCode(1,:) = [eventSides(1), num2str(eventTypes(1))];
if eventTimes(2) == eventTimes(1)
    optimCode(2,:) = [eventSides(2), num2str(eventTypes(2))];
    if eventTimes(3) == eventTimes(1)
        optimCode(3,:) =[eventSides(3), num2str(eventTypes(3))];
        if eventTimes(4) == eventTimes(1)
            optimCode(4,:) = [eventSides(4), num2str(eventTypes(4))];
            if eventTimes(5) == eventTimes(1)
              optimCode(5,:) =[eventSides(5), num2str(eventTypes(5))];
                if eventTimes(6) == eventTimes(1)
                   optimCode(6,:) = [eventSides(6), num2str(eventTypes(6))];
                end
            end
        end
    end
end


%%  Determine 1st and last frames over which optimisation routines are to
%   be run
%   LJC
match = regexp(cellstr(optimCode),'L1');
if max(cell2mat(match)) == 1;
    LHJC = 1;
    index = regexp(cellstr(eventSideType), 'L1');
    increment = 1;
    for i = 1:EventCount%6
        if index{i} == 1;
            indexLHJC(increment) = (i);
            increment = increment + 1;
        end
    end
    startLHJC = eventTimes(indexLHJC(2));
    endLHJC = eventTimes(indexLHJC(3));
else
    LHJC = 0;
end

%   RJC
match = regexp(cellstr(optimCode),'R1');
if max(cell2mat(match)) == 1;
    RHJC = 1;
    index = regexp(cellstr(eventSideType), 'R1');
    increment = 1;
    for i = 1:EventCount%6
        if index{i} == 1;
            indexRHJC(increment) = (i);
            increment = increment + 1;
        end
    end
    startRHJC = eventTimes(indexRHJC(2));
    endRHJC = eventTimes(indexRHJC(3));
else
    RHJC = 0;
end

%   LE F/E
match = regexp(cellstr(optimCode),'L2');
if max(cell2mat(match)) == 1;
    LKJA = 1;
    index = regexp(cellstr(eventSideType), 'L2');
    increment = 1;
    for i = 1:EventCount%6
        if index{i} == 1;
            indexLKJA(increment) = (i);
            increment = increment + 1;
        end
    end
    startLKJA = eventTimes(indexLKJA(2));
    endLKJA = eventTimes(indexLKJA(3));
else
    LKJA = 0;
end

%   RE F/E
match = regexp(cellstr(optimCode),'R2');
if max(cell2mat(match)) == 1;
    RKJA = 1;
    index = regexp(cellstr(eventSideType), 'R2');
    increment = 1;
    for i = 1:EventCount%6
        if index{i} == 1;
            indexRKJA(increment) = (i);
            increment = increment + 1;
        end
    end
    startRKJA = eventTimes(indexRKJA(2))
    endRKJA = eventTimes(indexRKJA(3));
else
    RKJA = 0;
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
    startREJA = eventTimes(indexREJA(2))
    endREJA = eventTimes(indexREJA(3));
else
    REJA = 0;
end

%%   Load model parameter file
cd(dataPath)
[variableName, equalSign, value]...
    = textread([subjectName '.mp'], '%s %s %s')

%   Check model parameter file to determine whether calculation of optimal
%   shoulder joint centre is required
if LHJC == 1 || RHJC == 1;
    optimalHipIndex = strmatch('$OptimalShoulder', variableName);
%    paramToOptimiseHJC = value(optimalHipIndex);
     paramToOptimiseHJC = strcmp('1', value(optimalHipIndex))
else
    paramToOptimiseHJC = 0;
end


%   Check model parameter file to determine whether calculation of mean
%   helical knee F/E axis is required
if LKJA == 1 || RKJA == 1;
    helicalKneeIndex = strmatch('$HelicalElbow', variableName);
 %  paramToOptimiseKJA = value(helicalKneeIndex);
    paramToOptimiseKJA = strcmp('1', value(helicalKneeIndex))
else
    paramToOptimiseKJA = 0;
end


% %   If performing hip joint centre optimisation, get InterASISdistance from
% %   model parameter file. If InterASISdistance was not physically measured
% %   it will be calculated from asis markers
% if LHJC == 1 || RHJC == 1;
%     interASISIndex = strmatch('$InterASISdist', variableName);
%     ASISdistance = strcmp('1',value(interASISIndex));
% else
%     ASISdistance = 0;
% end
% 
%   Check model parameter file to determine whether calculation of mean
%   helical knee S/A axis is required
if LEJA == 1 || REJA == 1;
    helicalElbowIndex = strmatch('$HelicalElbow', variableName);
    paramToOptimiseEJA = strcmp('1', value(helicalElbowIndex));
else
    paramToOptimiseEJA = 0;
end

% Run specified optimisation routine(s)
%%   LHJC
if LHJC == 1 && paramToOptimiseHJC == 1
    %   Define trajectory indexes for the required trajectories
    TrajectoryCount = double(invoke(hTrial, 'TrajectoryCount'));
    TrajectoryIndex_LASI = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LACR3', 0));
    TrajectoryIndex_RASI = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LACR1', 0));
    TrajectoryIndex_SACR = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LACR2', 0));
    TrajectoryIndex_LTH1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA1', 0));
    TrajectoryIndex_LTH2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA2', 0));
    TrajectoryIndex_LTH3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA3', 0));


    %   Get handles to all required trajectories
    hTrajectory_SACR = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_SACR));
    hTrajectory_LASI = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LASI));
    hTrajectory_RASI = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RASI));
    hTrajectory_LTH1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH1));
    hTrajectory_LTH2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH2));
    hTrajectory_LTH3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH3));



    %   Get trajectories required for optimisation
    SACR = (invoke(hTrajectory_SACR, 'GetPoints', startLHJC, endLHJC))';
    LASI = (invoke(hTrajectory_LASI, 'GetPoints', startLHJC, endLHJC))';
    RASI = (invoke(hTrajectory_RASI, 'GetPoints', startLHJC, endLHJC))';
    LTH1 = (invoke(hTrajectory_LTH1, 'GetPoints', startLHJC, endLHJC))';
    LTH2 = (invoke(hTrajectory_LTH2, 'GetPoints', startLHJC, endLHJC))';
    LTH3 = (invoke(hTrajectory_LTH3, 'GetPoints', startLHJC, endLHJC))';



    %   Release handles to required trajectories

    release(hTrajectory_SACR);
    release(hTrajectory_LASI);
    release(hTrajectory_RASI);
    release(hTrajectory_LTH1);
    release(hTrajectory_LTH2);
    release(hTrajectory_LTH3);

    %   Run optimisation code
   % findleftsjc_unconstrained_CTT1;
    PECS_findLeftHJCUnconstrained;

    %   Update values obtained from mp file
    for i = 1:length(variableName)
        if strcmp(char(variableName(i)), '$LeftOptimalShoulder');
            a=sprintf('{%f,%f,%f}',leftOptimalHipX,leftOptimalHipY,leftOptimalHipZ);
            s = struct('strings',a);
            value(i) =  struct2cell(s);
        end
    end
end

%%   RHJC
if RHJC == 1 && paramToOptimiseHJC == 1
    %   Define trajectory indexes for the required trajectories
    TrajectoryCount = double(invoke(hTrial, 'TrajectoryCount'));
    TrajectoryIndex_LASI = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RACR3', 0));
    TrajectoryIndex_RASI = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RACR1', 0));
    TrajectoryIndex_SACR = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RACR2', 0));
    TrajectoryIndex_RTH1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA1', 0));
    TrajectoryIndex_RTH2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA2', 0));
    TrajectoryIndex_RTH3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA3', 0));

    
    %   Get handles to all required trajectories
    hTrajectory_SACR = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_SACR));
    hTrajectory_LASI = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LASI));
    hTrajectory_RASI = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RASI));
    hTrajectory_RTH1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH1));
    hTrajectory_RTH2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH2));
    hTrajectory_RTH3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH3));



    %   Get trajectories required for optimisation
    SACR = (invoke(hTrajectory_SACR, 'GetPoints', startRHJC, endRHJC))';
    LASI = (invoke(hTrajectory_LASI, 'GetPoints', startRHJC, endRHJC))';
    RASI = (invoke(hTrajectory_RASI, 'GetPoints', startRHJC, endRHJC))';
    RTH1 = (invoke(hTrajectory_RTH1, 'GetPoints', startRHJC, endRHJC))';
    RTH2 = (invoke(hTrajectory_RTH2, 'GetPoints', startRHJC, endRHJC))';
    RTH3 = (invoke(hTrajectory_RTH3, 'GetPoints', startRHJC, endRHJC))';


    
    %   Release handles to required trajectories

    release(hTrajectory_SACR);
    release(hTrajectory_LASI);
    release(hTrajectory_RASI);
    release(hTrajectory_RTH1);
    release(hTrajectory_RTH2);
    release(hTrajectory_RTH3);

    %   Run optimisation code
    PECS_findRightHJCUnconstrained;

    %   Update values obtained from mp file
    for i = 1:length(variableName)
        if strcmp(char(variableName(i)), '$RightOptimalShoulder');
            a=sprintf('{%f,%f,%f}',rightOptimalHipX,rightOptimalHipY,rightOptimalHipZ)
            s = struct('strings',a);
            value(i) =  struct2cell(s);
        end
    end
end

% Run specified optimisation routine(s)
%%   LKJA
if LKJA == 1 && paramToOptimiseKJA == 1
    %   Define trajectory indexes for the required trajectories
    TrajectoryCount = double(invoke(hTrial, 'TrajectoryCount'));
    TrajectoryIndex_LTH1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA1', 0));
    TrajectoryIndex_LTH2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA2', 0));
    TrajectoryIndex_LTH3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA3', 0));
    TrajectoryIndex_LTB1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA1', 0));
    TrajectoryIndex_LTB2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA2', 0));
    TrajectoryIndex_LTB3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA3', 0));

    %   Get handles to all required trajectories
    hTrajectory_LTH1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH1));
    hTrajectory_LTH2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH2));
    hTrajectory_LTH3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH3));
    hTrajectory_LTB1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTB1));
    hTrajectory_LTB2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTB2));
    hTrajectory_LTB3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTB3));

    %   Get trajectories required for optimisation
    LTH1 = (invoke(hTrajectory_LTH1, 'GetPoints', startLKJA, endLKJA))';
    LTH2 = (invoke(hTrajectory_LTH2, 'GetPoints', startLKJA, endLKJA))';
    LTH3 = (invoke(hTrajectory_LTH3, 'GetPoints', startLKJA, endLKJA))';
    LTB1 = (invoke(hTrajectory_LTB1, 'GetPoints', startLKJA, endLKJA))';
    LTB2 = (invoke(hTrajectory_LTB2, 'GetPoints', startLKJA, endLKJA))';
    LTB3 = (invoke(hTrajectory_LTB3, 'GetPoints', startLKJA, endLKJA))';

    %   Release handles to required trajectories
    release(hTrajectory_LTH1);
    release(hTrajectory_LTH2);
    release(hTrajectory_LTH3);
    release(hTrajectory_LTB1);
    release(hTrajectory_LTB2);
    release(hTrajectory_LTB3);

    LTH = [LTH1, LTH2, LTH3];
    LTB = [LTB1, LTB2, LTB3];


    PECS_lefthelicalknee;

    %   Update values obtained from mp file
    for i = 1:length(variableName)
        if strcmp(char(variableName(i)), '$LEnHA1');
            a=sprintf('{%f,%f,%f}',LKHA1(1),LKHA1(2),LKHA1(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s)
        elseif strcmp(char(variableName(i)), '$LEnHA2');
            a=sprintf('{%f,%f,%f}',LKHA2(1),LKHA2(2),LKHA2(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s)
      
        end
    end
end


%%  RKJA
if RKJA == 1 && paramToOptimiseKJA == 1
    %   Define trajectory indexes for the required trajectories
    TrajectoryCount = double(invoke(hTrial, 'TrajectoryCount'));
    TrajectoryIndex_RTH1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA1', 0));
    TrajectoryIndex_RTH2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA2', 0));
    TrajectoryIndex_RTH3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA3', 0));
    TrajectoryIndex_RTB1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA1', 0));
    TrajectoryIndex_RTB2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA2', 0));
    TrajectoryIndex_RTB3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA3', 0));

    %   Get handles to all required trajectories
    hTrajectory_RTH1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH1));
    hTrajectory_RTH2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH2));
    hTrajectory_RTH3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH3));
    hTrajectory_RTB1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTB1));
    hTrajectory_RTB2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTB2));
    hTrajectory_RTB3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTB3));

    %   Get trajectories required for optimisation
    RTH1 = (invoke(hTrajectory_RTH1, 'GetPoints', startRKJA, endRKJA))';
    RTH2 = (invoke(hTrajectory_RTH2, 'GetPoints', startRKJA, endRKJA))';
    RTH3 = (invoke(hTrajectory_RTH3, 'GetPoints', startRKJA, endRKJA))';
    RTB1 = (invoke(hTrajectory_RTB1, 'GetPoints', startRKJA, endRKJA))';
    RTB2 = (invoke(hTrajectory_RTB2, 'GetPoints', startRKJA, endRKJA))';
    RTB3 = (invoke(hTrajectory_RTB3, 'GetPoints', startRKJA, endRKJA))';

    %   Release handles to required trajectories
    release(hTrajectory_RTH1);
    release(hTrajectory_RTH2);
    release(hTrajectory_RTH3);
    release(hTrajectory_RTB1);
    release(hTrajectory_RTB2);
    release(hTrajectory_RTB3);

    RTH = [RTH1, RTH2, RTH3];
    RTB = [RTB1, RTB2, RTB3];

    %   Calculate mean helical axis
    PECS_righthelicalknee;
    
    faiouyas=RKHA1
    
    %   Update values obtained from mp file
    for i = 1:length(variableName)
        if strcmp(char(variableName(i)),'$REnHA1');
            a=sprintf('{%f,%f,%f}',RKHA1(1),RKHA1(2),RKHA1(3))
            s = struct('strings',a);
            value(i) =  struct2cell(s)
        elseif strcmp(char(variableName(i)),'$REnHA2');
            a=sprintf('{%f,%f,%f}',RKHA2(1),RKHA2(2),RKHA2(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s)
        end
    end
end

% Run specified optimisation routine(s)
%%   LEJA
if LEJA == 1 && paramToOptimiseEJA == 1
    %   Define trajectory indexes for the required trajectories
    TrajectoryCount = double(invoke(hTrial, 'TrajectoryCount'));
    TrajectoryIndex_LTH1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA1', 0));
    TrajectoryIndex_LTH2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA2', 0));
    TrajectoryIndex_LTH3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LUA3', 0));
    TrajectoryIndex_LTB1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA1', 0));
    TrajectoryIndex_LTB2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA2', 0));
    TrajectoryIndex_LTB3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'LFA3', 0));

    %   Get handles to all required trajectories
    hTrajectory_LTH1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH1));
    hTrajectory_LTH2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH2));
    hTrajectory_LTH3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTH3));
    hTrajectory_LTB1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTB1));
    hTrajectory_LTB2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTB2));
    hTrajectory_LTB3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_LTB3));

    %   Get trajectories required for optimisation
    LTH1 = (invoke(hTrajectory_LTH1, 'GetPoints', startLEJA, endLEJA))';
    LTH2 = (invoke(hTrajectory_LTH2, 'GetPoints', startLEJA, endLEJA))';
    LTH3 = (invoke(hTrajectory_LTH3, 'GetPoints', startLEJA, endLEJA))';
    LTB1 = (invoke(hTrajectory_LTB1, 'GetPoints', startLEJA, endLEJA))';
    LTB2 = (invoke(hTrajectory_LTB2, 'GetPoints', startLEJA, endLEJA))';
    LTB3 = (invoke(hTrajectory_LTB3, 'GetPoints', startLEJA, endLEJA))';

    %   Release handles to required trajectories
    release(hTrajectory_LTH1);
    release(hTrajectory_LTH2);
    release(hTrajectory_LTH3);
    release(hTrajectory_LTB1);
    release(hTrajectory_LTB2);
    release(hTrajectory_LTB3);

    LTH = [LTH1, LTH2, LTH3];
    LTB = [LTB1, LTB2, LTB3];


    PECS_lefthelicalelbow;

    %   Update values obtained from mp file
    for i = 1:length(variableName)
        if strcmp(char(variableName(i)), '$LEspHA1');
            a=sprintf('{%f,%f,%f}',LEHA1(1),LEHA1(2),LEHA1(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s)
        elseif strcmp(char(variableName(i)), '$LEspHA2');
            a=sprintf('{%f,%f,%f}',LEHA2(1),LEHA2(2),EHA2(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s)
        end
    end
end


%%  REJA
if REJA == 1 && paramToOptimiseEJA == 1
    %   Define trajectory indexes for the required trajectories
    TrajectoryCount = double(invoke(hTrial, 'TrajectoryCount'));
    TrajectoryIndex_RTH1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA1', 0));
    TrajectoryIndex_RTH2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA2', 0));
    TrajectoryIndex_RTH3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RUA3', 0));
    TrajectoryIndex_RTB1 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA1', 0));
    TrajectoryIndex_RTB2 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA2', 0));
    TrajectoryIndex_RTB3 = double(invoke(hTrial,...
        'FindTrajectoryIndex', 'RFA3', 0));

    %   Get handles to all required trajectories
    hTrajectory_RTH1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH1));
    hTrajectory_RTH2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH2));
    hTrajectory_RTH3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTH3));
    hTrajectory_RTB1 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTB1));
    hTrajectory_RTB2 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTB2));
    hTrajectory_RTB3 = invoke(hTrial, 'Trajectory',...
        num2str(TrajectoryIndex_RTB3));

    %   Get trajectories required for optimisation
    RTH1 = (invoke(hTrajectory_RTH1, 'GetPoints', startREJA, endREJA))';
    RTH2 = (invoke(hTrajectory_RTH2, 'GetPoints', startREJA, endREJA))';
    RTH3 = (invoke(hTrajectory_RTH3, 'GetPoints', startREJA, endREJA))';
    RTB1 = (invoke(hTrajectory_RTB1, 'GetPoints', startREJA, endREJA))';
    RTB2 = (invoke(hTrajectory_RTB2, 'GetPoints', startREJA, endREJA))';
    RTB3 = (invoke(hTrajectory_RTB3, 'GetPoints', startREJA, endREJA))';

    %   Release handles to required trajectories
    release(hTrajectory_RTH1);
    release(hTrajectory_RTH2);
    release(hTrajectory_RTH3);
    release(hTrajectory_RTB1);
    release(hTrajectory_RTB2);
    release(hTrajectory_RTB3);

    RTH = [RTH1, RTH2, RTH3];
    RTB = [RTB1, RTB2, RTB3];

    %   Calculate mean helical axis
    PECS_righthelicalelbow;

    %   Update values obtained from mp file
    for i = 1:length(variableName)
        if strcmp(char(variableName(i)), '$REspHA1');
            a=sprintf('{%f,%f,%f}',REHA1(1),REHA1(2),REHA1(3))
            s = struct('strings',a)
            value(i) =  struct2cell(s)
        elseif strcmp(char(variableName(i)), '$REspHA2');
            a=sprintf('{%f,%f,%f}',REHA2(1),REHA2(2),REHA2(3));
            s = struct('strings',a);
            value(i) =  struct2cell(s)
        end
    end
end


%%   Overwrite existing model parameter file


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
