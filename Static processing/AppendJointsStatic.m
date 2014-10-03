% Append Joint axis and Centers from External files (.vmc & .fjc)     **
    % Author: James Dunne (dunne.jimmy@gmail.com)
    %          Thor Besier
    %          Cyril J Donnelly 
    % Created: Janurary 2010
    % Updated: April 2012
    %
    %
%% Use functional joints (=1), anatomical (=0), or both (=2)
functionaljoints =  1;

%% Define cluster names 
pelvis=[{'RASI'} {'LASI'} {'RPSI'} {'LPSI'}];
rightthigh=[{'RTH1'} {'RTH2'} {'RTH3'}]; 
leftthigh=[{'LTH1'} {'LTH2'} {'LTH3'}]; 
righttibia=[{'RTB1'} {'RTB2'} {'RTB3'}];
leftttibia=[{'LTB1'} {'LTB2'} {'LTB3'}];

%% Specify axis
% Left ankle
Axis_Leftankle=[{'LLMAL'} {'LMMAL'} {'LAJC'}];
% Right ankle
Axis_Rightankle=[{'RLMAL'} {'RMMAL'} {'LAJC'}];
% Left Knee
ana_LeftKnee=[{'LLFC'} {'LMFC'} {'LKJC'}];
fun_LeftKnee=[{'fun_LLFC'} {'fun_LMFC'} {'fun_LKJC'}];
% Right Knee
ana_RightKnee=[{'RLFC'} {'RMFC'} {'RKJC'}];
fun_RightKnee=[{'fun_RLFC'} {'fun_RMFC'} {'fun_RKJC'}];    
   

%% Specify if there is condyle data in folder to use(from pointer trials)
PointerCondyle=1;

%% Interact with the Pecs server
global  hServer;
global  hTrial;
global  hProcessor;
global  hParamStore;
global  hEvStore;

hServer = actxserver( 'PECS.Document' );
invoke( hServer, 'Refresh' );

hTrial = get(hServer, 'Trial' );
hProcessor = get(hServer, 'Processor' );
hParamStore = get(hTrial, 'ParameterStore' );
hEvStore = get(hTrial, 'EventStore' );



%% Create strucutre with all marker names in the trial
        [MarkerStruct,trial_name, dat_path,analog_rate,sampleRate,First,Last] =  MarkerDataViaPecs(hTrial);

%% Append condyle data produced from pointer trials.

if PointerCondyle==1
    Functiondirectory=cd;
    cd(dat_path);
    condyles=dir('*.vpc');

    if isempty(condyles)
        CondyleStruct(1)= structureOutofStructure(MarkerStruct,{'LLFC'});
        CondyleStruct(2)= structureOutofStructure(MarkerStruct,{'LMFC'});
        CondyleStruct(3)= structureOutofStructure(MarkerStruct,{'RLFC'});
        CondyleStruct(4)= structureOutofStructure(MarkerStruct,{'RMFC'});
    else
    % take the condyle data and create a structure out of it
    for ii=1:length(condyles)
            name = regexprep(condyles(ii).name, '.vpc', '');
            filename=[dat_path condyles(ii).name];
            CondyleData = importdata(filename);
            
            
            if isempty(strfind(name,'R'))==1 ; % doesnt have a 'R' so left
                ParentMarkers=leftthigh;
                    if isempty(strfind(name,'LL'))
                        newname=ana_LeftKnee(2);
                    else
                        newname=ana_LeftKnee(1);
                    end
            else                               % does have a 'R' so right
                ParentMarkers=rightthigh;
                	if isempty(strfind(name,'RL'))
                        newname=ana_RightKnee(2);
                    else
                        newname=ana_RightKnee(1);
                    end
            end
           
            
           %    Get the data for the parent markers     
           [ParentMarkerStruct] = structureOutofStructure(MarkerStruct,ParentMarkers);
           %    place the condyle data in the global
           [GlobalCondyle]= MovePoint_Global(ParentMarkerStruct,CondyleData);
           %    Print condyle data to c3d
           [output_args] = createC3Dtrajectory(hTrial,newname,GlobalCondyle,First,Last)
           %    Place in a structure
           CondyleStruct(ii)=struct('Name', {newname},'Data', {GlobalCondyle});
    end
           MarkerStruct(length(MarkerStruct)+1:length(MarkerStruct)+ii)=CondyleStruct;
    end
end    
    
  
%% functional joint and axis creation
if functionaljoints~= 0
    
                Functiondirectory=cd;
                cd(dat_path);
                FunctionJointPositions=dir('*JC.fjc'); % find all the functional joint files
                nFunJoints=length(FunctionJointPositions);
                cd(Functiondirectory);

    for w=1:nFunJoints         

        % Output the name and file path for the axis data
            
             Name = regexprep(FunctionJointPositions(w).name, '.fjc', '');
             JointName=Name;
             filepath=[dat_path FunctionJointPositions(w).name]; 


        % Get the axes names and data into some structures            
            newData = importdata(filepath);
        	CoordinateData=newData.data;

     if JointName=='HJC'
            [ProxStruct] = structureOutofStructure(MarkerStruct,pelvis);
            sacrstruct=struct('Name', {'SACR'},'Data', {(ProxStruct(3).Data+ProxStruct(4).Data)/2});
            PelvisStruct=[ProxStruct(1) ProxStruct(2) sacrstruct];

             % Left Hip
            [LHJC]  =  CoordinateData(:,1)';
            [Globalhip]= MovePoint_Global(PelvisStruct,CoordinateData(:,1));
            [output_args] = createC3Dtrajectory(hTrial,'fun_LHJC',Globalhip,First,Last)

            % Right Hip
            [RHJC]  =  CoordinateData(:,2)';
            [Globalhip]= MovePoint_Global(PelvisStruct,CoordinateData(:,2));
            [output_args] = createC3Dtrajectory(hTrial,'fun_RHJC',Globalhip,First,Last)

     end


    if JointName =='KJC'
            [LthighStruct] = structureOutofStructure(MarkerStruct,leftthigh);
            [CondlyeDataStruct] = structureOutofStructure(MarkerStruct,ana_LeftKnee(1:2));
            [fun_LKJC,fun_LLFC,fun_LMFC]=CreateHelicalJoint(LthighStruct,CondlyeDataStruct,CoordinateData(:,1),CoordinateData(:,2));
            
            
            [output_args] = createC3Dtrajectory(hTrial,'fun_LKJC',fun_LKJC,First,Last)
            [output_args] = createC3Dtrajectory(hTrial,'fun_LLFC',fun_LLFC,First,Last)
            [output_args] = createC3Dtrajectory(hTrial,'fun_LMFC',fun_LMFC,First,Last)


            [RthighStruct] = structureOutofStructure(MarkerStruct,rightthigh);
            [CondlyeDataStruct] = structureOutofStructure(MarkerStruct,ana_RightKnee(1:2));
            [fun_RKJC,fun_RLFC,fun_RMFC]=CreateHelicalJoint(RthighStruct,CondlyeDataStruct,CoordinateData(:,3),CoordinateData(:,4));
            
            
            [output_args] = createC3Dtrajectory(hTrial,'fun_RKJC',fun_RKJC,First,Last)
            [output_args] = createC3Dtrajectory(hTrial,'fun_RLFC',fun_RLFC,First,Last)
            [output_args] = createC3Dtrajectory(hTrial,'fun_RMFC',fun_RMFC,First,Last)

    end
    % if JointName=='AJC'
    %         [Ltibiastruct] = DataOutofSturcture(MarkerStruct,leftttibia);
    %         [CondlyeDataStruct] =
    %         DataOutofSturcture(MarkerStruct,[{'LLMAL'} {'LMMAL'}]);
    %         [fun_LAJC,fun_LLAJC,fun_LMAJC]=CreateHelicalJoint(Ltibiastruct,CondlyeDataStruct,CoordinateData(:,1),CoordinateData(:,2));
    %  
    %         [output_args] = createC3Dtrajectory(hTrial,'fun_LAJC',fun_LAJC,First,Last)
    %         [output_args] = createC3Dtrajectory(hTrial,'fun_LLAJC',fun_LLAJC,First,Last)
    %         [output_args] = createC3Dtrajectory(hTrial,'fun_LMAJC',fun_LMAJC,First,Last)
    %      
    %         
    %         [Rtibiastruct] = DataOutofSturcture(MarkerStruct,righttibia);
    %         [CondlyeDataStruct] = DataOutofSturcture(MarkerStruct,[{'RLMAL'} {'RMMAL'}]);
    %         [fun_RAJC,fun_RLAJC,fun_RMAJC]=CreateHelicalJoint(Rtibiastruct,CondlyeDataStruct,CoordinateData(:,3),CoordinateData(:,4));
    %  
    %         [output_args] = createC3Dtrajectory(hTrial,'fun_RAJC',fun_RAJC,First,Last)
    %         [output_args] = createC3Dtrajectory(hTrial,'fun_RLAJC',fun_RLAJC,First,Last)
    %         [output_args] = createC3Dtrajectory(hTrial,'fun_RMAJC',fun_RMAJC,First,Last)
    %         
    % end
    end
end
%% Anatomical joint creation

if functionaljoints~= 1
    % Left ankle
    [Left_Axis_data] = DataOutofSturcture(MarkerStruct,Axis_Leftankle(1:2));
    Axis_data=(Left_Axis_data(1).Data+Left_Axis_data(2).Data)/2;
    [output_args] = createC3Dtrajectory(hTrial,char(Axis_Leftankle(3)),Axis_data,First,Last);
    
    % Right ankle
    [Right_Axis_data] = DataOutofSturcture(MarkerStruct,Axis_Rightankle(1:2));
    Axis_data=(Axis_data(1).Data+Axis_data(2).Data)/2;
    [output_args] = createC3Dtrajectory(hTrial,char(Axis_Leftankle(3)),Axis_data,First,Last);

    
    
    % HJC from regression equation                    
    [ProxStruct] = DataOutofSturcture(MarkerStruct,pelvis);
    sacrstruct=struct('Name', {'SACR'},'Data', {(ProxStruct(3).Data+ProxStruct(4).Data)/2});
    PelvisStruct=[ProxStruct(1) ProxStruct(2) sacrstruct];

    [ OrthotrackHipStruct ] = OrthotrakHJC(PelvisStruct);
    % Save the Data Back the C3D File
    for tt=1:length(OrthotrackHipStruct)
    [ output_args ] = createC3Dtrajectory(hTrial,...
                                    char(OrthotrackHipStruct(tt).Name),...
                                    OrthotrackHipStruct(tt).Data'...
                                    ,First,Last);
    end
    
end

%% Specify axis and export

% define parent systems
    [lefttib] = structureOutofStructure(MarkerStruct,leftttibia);
    [righttib] = structureOutofStructure(MarkerStruct,righttibia);
% Get the marker in the global

    [leftfemur] = structureOutofStructure(MarkerStruct,leftthigh);
    [rightfemur] = structureOutofStructure(MarkerStruct,rightthigh);
    
    [ LLFC ] = MoveToTechnicalCS(leftfemur,mean(fun_LLKJC));
    [ LMFC ] = MoveToTechnicalCS(leftfemur, mean(fun_LMKJC));
    [ LKJC ]  = MoveToTechnicalCS(leftfemur, mean(fun_LKJC));    
    [ RLFC ] = MoveToTechnicalCS(rightfemur,mean(fun_RLKJC));
    [ RMFC ] = MoveToTechnicalCS(rightfemur, mean(fun_RMKJC));
    [ RKJC ]  = MoveToTechnicalCS(rightfemur, mean(fun_RKJC));
    
    [RLMAL] = structureOutofStructure(MarkerStruct,{'RLMAL'});
    [RMMAL] = structureOutofStructure(MarkerStruct,{'RMMAL'});
    [LLMAL] = structureOutofStructure(MarkerStruct,{'LLMAL'});
    [LMMAL] = structureOutofStructure(MarkerStruct,{'LMMAL'});
   
    [ LLMAL ] = MoveToTechnicalCS(lefttib, LLMAL.Data);
    [ LMMAL ] = MoveToTechnicalCS(lefttib, LMMAL.Data);
    [ LAJC ]  = (LLMAL+LMMAL)/2;

    [ RLMAL ] = MoveToTechnicalCS(righttib, RLMAL.Data);
    [ RMMAL ] = MoveToTechnicalCS(righttib, RMMAL.Data);
    [ RAJC ]  = (RLMAL+RMMAL)/2;
    
%%

% Print to file
    output_file = [dat_path 'Kane_Static.mp'];
    fid = fopen(output_file,'w');

        fprintf(fid,'%s\t%s\t','LHJC'); fprintf(fid,'%f\t',LHJC);  fprintf(fid,'\n'); 
        fprintf(fid,'%s\t%s\t','RHJC'); fprintf(fid,'%f\t',RHJC);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','LLFC'); fprintf(fid,'%f\t',LLFC);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','LMFC'); fprintf(fid,'%f\t',LMFC);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','RLFC'); fprintf(fid,'%f\t',RLFC);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','RMFC'); fprintf(fid,'%f\t',RMFC);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','LLMAL'); fprintf(fid,'%f\t',LLMAL);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','LMMAL'); fprintf(fid,'%f\t',LMMAL);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','RLMAL'); fprintf(fid,'%f\t',RLMAL);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','RMMAL'); fprintf(fid,'%f\t',RMMAL);  fprintf(fid,'\n');
        
        fprintf(fid,'%s\t%s\t','LKJC'); fprintf(fid,'%f\t',LKJC);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','RKJC'); fprintf(fid,'%f\t',RKJC);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','RAJC'); fprintf(fid,'%f\t',RAJC);  fprintf(fid,'\n');
        fprintf(fid,'%s\t%s\t','LAJC'); fprintf(fid,'%f\t',LAJC);  fprintf(fid,'\n');

        fclose(fid); 

%% Close Pecs processing

release( hEvStore );
release( hParamStore );
release( hTrial );
release( hServer );













