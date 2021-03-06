
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

%% functional analysis?
    fun=1;
%% Interact with the PECS server to pull create a structure %%
[MarkerStruct,trial_name, dat_path,analog_rate,sampleRate,First,Last] =  MarkerDataViaPecs(hTrial);
%% Filter the data
filt_MarkerStruct=MarkerStruct;
Fcut=8;
for ii=1:length(MarkerStruct)
            filt_MarkerStruct(ii).Data= filterData(Fcut,sampleRate,MarkerStruct(ii).Data);
end
%% Define the segment/joint dependencies (labels)

    %Trunk
        trunk ={'C7' 'T10' 'CLAV' 'STRN'};
    %Pelvis
        Pelvis ={'LASI' 'RASI' 'LPSI' 'RPSI'};
    % Define markers for each segment
        r.femur= {'RTH1' 'RTH2' 'RTH3'};
        r.tibia= {'RTB1' 'RTB2' 'RTB3'};
    
        l.femur= {'LTH1' 'LTH2' 'LTH3'};
        l.tibia= {'LTB1' 'LTB2' 'LTB3'};

        r.foot=[{'RCAL'} {'RMT1'} {'RMT2'}];
        l.foot=[{'LCAL'} {'LMT1'} {'LMT2'}];
    
    % Ankle joint
        r.ankle=[{'RAJC'} {'RMMAL'} {'RLMAL'}];
        l.ankle=[{'LAJC'} {'LMMAL'} {'LLMAL'}];

    % Define Anaotmical or functional model
    
    if fun==1
        % Hip joints
        r.hip=[{'fun_RHJC'}];
        l.hip=[{'fun_LHJC'}];
        % Knee joint
        r.knee=[{'fun_RKJC'} {'fun_RMKJC'} {'fun_RLKJC'}];
        l.knee=[{'fun_LKJC'} {'fun_LMKJC'} {'fun_LLKJC'}];
        model='fun';
    else
        % Hip joints
        r.hip=[{'RHJC'}];
        l.hip=[{'LHJC'}];
        % Knee joint
        r.knee=[{'RKJC'} {'RMFC'} {'RLFC'}];
        l.knee=[{'LKJC'} {'LMFC'} {'LLFC'}];
        model='ana';
    end

%% Import joint center and axis data from MP file

    cd(dat_path);
    mpfile=dir('*tatic.mp'); % find all the functional joint files
    filepath=[dat_path mpfile.name];
    mpdata = importdata(filepath);

   
     for i=1:length(mpdata.textdata)
             jointStruct(i) = struct('Name', {char(mpdata.textdata(i))},'Data', {mpdata.data(i,:)});
     end
     
        [RHJC] = datafromStruct(jointStruct, {'RHJC'} ); 
        [RKJC] = datafromStruct(jointStruct, {'RKJC'} );
        [RAJC] = datafromStruct(jointStruct, {'RAJC'} );
        [RLFC] = datafromStruct(jointStruct, {'RLFC'} ); 
        [RMFC] = datafromStruct(jointStruct, {'RMFC'} ); 
        [RLMAL] = datafromStruct(jointStruct, {'RLMAL'} ); 
        [RMMAL] = datafromStruct(jointStruct, {'RMMAL'} );
        
        
        [LHJC] = datafromStruct(jointStruct,  {'LHJC'} );
        [LKJC] = datafromStruct(jointStruct,  {'LKJC'} );
        [LAJC] = datafromStruct(jointStruct,  {'LAJC'} );
        [LLFC] = datafromStruct(jointStruct,  {'LLFC'} ); 
        [LMFC] = datafromStruct(jointStruct,  {'LMFC'} ); 
        [LLMAL] = datafromStruct(jointStruct, {'LLMAL'} ); 
        [LMMAL] = datafromStruct(jointStruct, {'LMMAL'} );
        %      for ii=1:length(mpdata.textdata)
        %              eval([ char(mpdata.textdata(ii)) '= mpdata.data(ii,:)']);
        %      end
 
%% Dump markers into the workspace

        [LASI] = datafromStruct(MarkerStruct, Pelvis(1) ); % Left Anterior
        [RASI] = datafromStruct(MarkerStruct, Pelvis(2) ); % Right Anterior
        [LPSI] = datafromStruct(MarkerStruct, Pelvis(3) ); % Left Posterior
        [RPSI] = datafromStruct(MarkerStruct, Pelvis(4) ); % Right Posterior
        [SACR]  = (LPSI+RPSI)/2;
        [MidPEL]= (LASI+RASI)/2;
        [Opelvis]= MidPEL;

        [LTH1] = datafromStruct(MarkerStruct, r.femur(1) ); % Left Anterior
        [LTH2] = datafromStruct(MarkerStruct, r.femur(2) ); % Right Anterior
        [LTH3] = datafromStruct(MarkerStruct, r.femur(3) ); % Left Posterior
        
        [RTH1] = datafromStruct(MarkerStruct, r.femur(1) ); % Left Anterior
        [RTH2] = datafromStruct(MarkerStruct, r.femur(2) ); % Right Anterior
        [RTH3] = datafromStruct(MarkerStruct, r.femur(3) ); % Left Posterior
        
        [LTB1] = datafromStruct(MarkerStruct, r.tibia(1) ); % Left Anterior
        [LTB2] = datafromStruct(MarkerStruct, r.tibia(2) ); % Right Anterior
        [LTB3] = datafromStruct(MarkerStruct, r.tibia(3) ); % Left Posterior
        
        [RTB1] = datafromStruct(MarkerStruct, r.tibia(1) ); % Left Anterior
        [RTB2] = datafromStruct(MarkerStruct, r.tibia(2) ); % Right Anterior
        [RTB3] = datafromStruct(MarkerStruct, r.tibia(3) ); % Left Posterior
        
        % Segment Markers  
    
        [C7]   = datafromStruct(MarkerStruct,  trunk(1)  );   
        [T10]  = datafromStruct(MarkerStruct,  trunk(2)  );
        [CLAV] = datafromStruct(MarkerStruct,  trunk(3)  );
        [STRN] = datafromStruct(MarkerStruct,  trunk(4)  );

        [RTH1] = datafromStruct(MarkerStruct,  r.femur(1));   
        [RTH2] = datafromStruct(MarkerStruct,  r.femur(2));
        [RTH3] = datafromStruct(MarkerStruct,  r.femur(3));   

        [RTB1] = datafromStruct(MarkerStruct,  r.tibia(1));   
        [RTB2] = datafromStruct(MarkerStruct,  r.tibia(2));
        [RTB3] = datafromStruct(MarkerStruct,  r.tibia(3));
           
        [LTH1] = datafromStruct(MarkerStruct,  l.femur(1));   
        [LTH2] = datafromStruct(MarkerStruct,  l.femur(2));
        [LTH3] = datafromStruct(MarkerStruct,  l.femur(3));   

        [LTB1] = datafromStruct(MarkerStruct,  l.tibia(1));   
        [LTB2] = datafromStruct(MarkerStruct,  l.tibia(2));
        [LTB3] = datafromStruct(MarkerStruct,  l.tibia(3));
        
        [RCAL] = datafromStruct(MarkerStruct,  r.foot(1) ); % Right Lateral Mal
        [RMT1] = datafromStruct(MarkerStruct,  r.foot(2) ); % Right Medial Mal
        [RMT2] = datafromStruct(MarkerStruct,  r.foot(3) ); % Right Lateral Mal
        
        [LCAL] = datafromStruct(MarkerStruct,  l.foot(1)       ); % Left Cal
        [LMT1] = datafromStruct(MarkerStruct,  l.foot(2)       ); % Left big toe
        [LMT2] = datafromStruct(MarkerStruct,  l.foot(3)       ); % Left little toe

%%  Project joint axis and centre markers into global        
        [ LHJC ] = MovePoint_Global([RASI LASI SACR], LHJC);
        [ RHJC ] = MovePoint_Global([RASI LASI SACR], RHJC);
        [output_args] = createC3Dtrajectory(hTrial,'LHJC',LHJC,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'RHJC',RHJC,First,Last);
    
        [ LLFC ] = MovePoint_Global([LTH1 LTH2 LTH3], LLFC);
        [ LMFC ] = MovePoint_Global([LTH1 LTH2 LTH3], LMFC);
        [ LKJC ] = MovePoint_Global([LTH1 LTH2 LTH3], LKJC);
        [output_args] = createC3Dtrajectory(hTrial,'LLFC',LLFC,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'LMFC',LMFC,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'LKJC',LKJC,First,Last);
        
        [ RLFC ] = MovePoint_Global([RTH1 RTH2 RTH3], RLFC);
        [ RMFC ] = MovePoint_Global([RTH1 RTH2 RTH3], RMFC);
        [ RKJC ] = MovePoint_Global([RTH1 RTH2 RTH3], RKJC);
        [output_args] = createC3Dtrajectory(hTrial,'RLFC',RLFC,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'RMFC',RMFC,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'RKJC',RKJC,First,Last);
        
        [LAJC] =  MovePoint_Global([LTB1 LTB2 LTB3], LAJC); 
        [LMMAL] = MovePoint_Global([LTB1 LTB2 LTB3], LMMAL); % Right Medial Mal
        [LLMAL] = MovePoint_Global([LTB1 LTB2 LTB3], LLMAL); % Right Lateral Mal
        [output_args] = createC3Dtrajectory(hTrial,'LAJC',LAJC,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'LMMAL',LMMAL,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'LLMAL',LLMAL,First,Last);
        
        [RAJC] =  MovePoint_Global([RTB1 RTB2 RTB3], RAJC);
        [RMMAL] = MovePoint_Global([RTB1 RTB2 RTB3], RMMAL); % Right Medial Mal
        [RLMAL] = MovePoint_Global([RTB1 RTB2 RTB3], RLMAL); % Right Lateral Mal
        [output_args] = createC3Dtrajectory(hTrial,'RAJC',RAJC,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'RMMAL',RMMAL,First,Last);
        [output_args] = createC3Dtrajectory(hTrial,'RLMAL',RLMAL,First,Last);
       

%% Global...........................................................
    
    % global written as z(lateral), x(anterior), y(superior/inferior) 
        Globalo= [0 1 0 0 0 1 1 0 0];
    % Fill Matrix
        Global=repmat(Globalo,length(MarkerStruct(1).Data),1);

%% Pelvis...........................................................
 % [Rpv, Tpv] = pelvisBAF(LASI, RASI, LPSI, RPSI) is equivalent to
 % Pelvis ={'LASI' 'RASI' 'LPSI' 'RPSI'};
 % Search & extract the markers needed
 
 % Run for the pelvis
        [pelvisSeg] = segmentsystem(RASI,LASI,MidPEL,SACR,'zyx');

%% Femur.............................................................
     % Calcualte femur coordinate systems  
        [R_femur] = segmentsystem(RLFC,RMFC,RHJC,RKJC,'zxy');
        [L_femur] = segmentsystem(LMFC,LLFC,LHJC,LKJC,'zxy');
        
 %% Tibia.............................................................
     % Rather than use an unreliable ankle axis to define the orientation
     % of the Tibia, We use the knee axis. This will give a very small 
     % rotation/adduction values during the static trial though...
     % May not be a valid way of representing clinically divergent knee
     
      % Calculate the Tibia coordinate systems   
        [R_tibia] = segmentsystem(RLFC,RMFC,RKJC,RAJC,'zxy');
        [L_tibia] = segmentsystem(LMFC,LLFC,LKJC,LAJC,'zxy'); 


%% Foot...............................................................
      % Zero the Y axis of the foot markers
        G_RCAL=RCAL; G_RCAL(:,3)=0; 
        G_RMT1=RMT1; G_RMT1(:,3)=0;
        G_RMT2=RMT2; G_RMT2(:,3)=0;
        
        R_Midfoot= (RMT1+RMT2)/2;
        RG_Midfoot=(G_RMT1+G_RMT2)/2;
    
      % Zero the Y axis of the foot markers
        G_LCAL=LCAL; G_LCAL(:,3)=0; 
        G_LMT1=LMT1; G_LMT1(:,3)=0;
        G_LMT2=LMT2; G_LMT2(:,3)=0;
        
        L_Midfoot= (LMT1+LMT2)/2;
        LG_Midfoot=(G_LMT1+G_LMT2)/2;
        
        
     % Calculate the Foot coordinate systems 
        [R_foot] = segmentsystem(RMT2,RMT1,R_Midfoot,RCAL,'zyx'); 
        [RG_foot] = segmentsystem(G_RMT2,G_RMT1,RG_Midfoot,G_RCAL,'zyx');
        
        [L_foot] = segmentsystem(LMT1,LMT2,L_Midfoot,LCAL,'zyx'); 
        [LG_foot] = segmentsystem(G_LMT1,G_LMT2,LG_Midfoot,G_LCAL,'zyx');
        
        Rfootoffset=jointangle(R_foot,RG_foot); 
        Lfootoffset=jointangle(L_foot,LG_foot); 

%% Calculate Joint angles between segment coordinate systems        
        
% Pelvis..........
    % Pitch(flexion), roll ( adduction) , yaw (rotation)
    % Since there isnt flexion adduction and rotation need to use these
    % terms
    PelvisAngle=jointangle(Global,pelvisSeg);
        Pelvis_Pitch=   (PelvisAngle(:,3));   
        Pelvis_roll=    (PelvisAngle(:,2));    
        Pelvis_yaw=     (PelvisAngle(:,1));    
% Trunk...........
        Trunk= -1*Pelvis_Pitch;  % Not calculate but needed in OpenSim               
% Hip.............
    R_Hip=jointangle(pelvisSeg,R_femur);
        R.Hip_flexion=  (R_Hip(:,3));     
        R.Hip_Adduction=(R_Hip(:,1));       
        R.Hip_Rotation= (R_Hip(:,2));      
    
    L_Hip=jointangle(pelvisSeg,L_femur);
        L.Hip_flexion=  (L_Hip(:,3));       
        L.Hip_Adduction=-1*(L_Hip(:,1));      
        L.Hip_Rotation= -1*(L_Hip(:,2));     
% Knee............    
    R_Knee=jointangle(R_femur,R_tibia);
        R.Knee_flexion=  (R_Knee(:,3));   
        R.Knee_Adduction=(R_Knee(:,1));    
        R.Knee_Rotation= (R_Knee(:,2));     
           
    L_Knee=jointangle(L_femur,L_tibia);
         L.Knee_flexion=  (L_Knee(:,3));   
         L.Knee_Adduction=-1*(L_Knee(:,1));   
         L.Knee_Rotation= -1*(L_Knee(:,2));   
% Ankle...........
    R_Ankle=jointangle(R_tibia, R_foot);
         R.Ankle_flexion=  (R_Ankle(:,3));  
         R.Ankle_Inversion=(R_Ankle(:,1));  
         R.Ankle_Rotation= (R_Ankle(:,2)); 
    
    L_Ankle=jointangle(L_tibia, L_foot);
         L.Ankle_flexion=  (L_Ankle(:,3)); 
         L.Ankle_Inversion=(L_Ankle(:,1)); 
         L.Ankle_Rotation= (L_Ankle(:,2));         

         L.footoffset_flexion=    (Lfootoffset(:,3)); 
         L.footoffset_Inversion=  (Lfootoffset(:,1)); 
         L.footoffset_Rotation=   (Lfootoffset(:,2)); 
         
         R.footoffset_flexion=    (Rfootoffset(:,3)); 
         R.footoffset_Inversion=  (Rfootoffset(:,1)); 
         R.footoffset_Rotation=   (Rfootoffset(:,2)); 
         
%% Print joint angle data

jointangleData=[Pelvis_Pitch Pelvis_roll Pelvis_yaw    ...
     R.Hip_flexion   R.Hip_Adduction   R.Hip_Rotation   ...
     R.Knee_flexion  R.Knee_Rotation   R.Knee_Adduction ...
     R.Ankle_flexion R.Ankle_Inversion R.Ankle_Rotation ...
     L.Hip_flexion   L.Hip_Adduction   L.Hip_Rotation   ...
     L.Knee_flexion  L.Knee_Rotation   L.Knee_Adduction...
     L.Ankle_flexion L.Ankle_Rotation  L.Ankle_Inversion ];
 
 jointangleNames=[{'Pelvis_Pitch' 'Pelvis_roll' 'Pelvis_yaw'    ...
     'R.Hip_flexion'   'R.Hip_Adduction'   'R.Hip_Rotation'   ...
     'R.Knee_flexion'  'R.Knee_Rotation'   'R.Knee_Adduction' ...
     'R.Ankle_flexion' 'R.Ankle_Inversion' 'R.Ankle_Rotation' ...
     'L.Hip_flexion'   'L.Hip_Adduction'   'L.Hip_Rotation' ...
     'L.Knee_flexion'  'L.Knee_Rotation'   'L.Knee_Adduction'...
     'L.Ankle_flexion' 'L.Ankle_Rotation'  'L.Ankle_Inversion'}];
    
    new_file = [dat_path trial_name '_directkinematics.trc'];
    fid = fopen(new_file,'w');    
    njoints=length(jointangleNames);
    
    for i = 1:njoints
        fprintf(fid,'%s\t',char(jointangleNames(i)));
    end
     fprintf(fid,'\n');
    
    [m n]= size(jointangleData);
    
    for i= 1:m
          fprintf(fid,'%2.4f\t',jointangleData(i,:));
          fprintf(fid,'\n');
    end 
      fclose(fid);
      
%%

release( hEvStore );
release( hParamStore );
release( hTrial );
release( hServer );       
























































