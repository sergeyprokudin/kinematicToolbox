% CAST Model of joint kinematics
    % Data input assumes being run through PECS server in VICON. 
    % MarkerStruct is a structure with length of markers and has
    % two levels (Data and Name)
    % MarkerSteuct.Data     =nX3 matrix of marker coordinates
    % MarkerSteuct.Name     'LASI'

%% Interact with the Pecs Server
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

%% Extract Data From C3D
        [MarkerStruct,trial_name, dat_path,analog_rate,sampleRate,First,Last] =  MarkerDataViaPecs(hTrial);
        
%% Orientate the data in positive X of room
        [ MarkerStruct,rot1 ] = rotateviconmarkers( MarkerStruct );

%% Define if using the functional model (fun=1)
    fun=1;
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


%% Dump the marker information into the workspace

% Joint axis and center Markers 
        [LASI] = datafromStruct(MarkerStruct, Pelvis(1) ); % Left Anterior
        [RASI] = datafromStruct(MarkerStruct, Pelvis(2) ); % Right Anterior
        [LPSI] = datafromStruct(MarkerStruct, Pelvis(3) ); % Left Posterior
        [RPSI] = datafromStruct(MarkerStruct, Pelvis(4) ); % Right Posterior
        [SACR]  = (LPSI+RPSI)/2;
        [MidPEL]= (LASI+RASI)/2;
        [Opelvis]= MidPEL;
        
        [RHJC]  = datafromStruct(MarkerStruct, r.hip    ); % Right Hip Joint Center
        [RMFC]  = datafromStruct(MarkerStruct, r.knee(2)); % Right Medial Femoral Condyle
        [RLFC]  = datafromStruct(MarkerStruct, r.knee(3)); % Right Lateral Femoral Condyle
        [RKJC]  = (RMFC+RLFC)/2;
        
        [RAJC]  = datafromStruct(MarkerStruct, r.ankle(1)); % Right Medial Mal
        [RMMAL] = datafromStruct(MarkerStruct, r.ankle(2)); % Right Medial Mal
        [RLMAL] = datafromStruct(MarkerStruct, r.ankle(3)); % Right Lateral Mal
         
        
        [LHJC]  = datafromStruct(MarkerStruct, l.hip    ); % Right Hip Joint Center
        [LMFC]  = datafromStruct(MarkerStruct, l.knee(2)); % Right Medial Femoral Condyle
        [LLFC]  = datafromStruct(MarkerStruct, l.knee(3)); % Right Lateral Femoral Condyle
        [LKJC]  = (LMFC+LLFC)/2;
        
        
        [LMMAL] = datafromStruct(MarkerStruct, l.ankle(2)); % Right Medial Mal
        [LLMAL] = datafromStruct(MarkerStruct, l.ankle(3)); % Right Lateral Mal
        [LAJC]  = (LMMAL+LLMAL)/2;                          % Right Medial Mal
        
% Segment Markers  
    
        [C7]   = datafromStruct(MarkerStruct,  trunk(1)  );   
        [T10]  = datafromStruct(MarkerStruct,  trunk(2)  );
        [CLAV] = datafromStruct(MarkerStruct,  trunk(3)  );
        [STRN] = datafromStruct(MarkerStruct,  trunk(4)  );

        [RTH1] = datafromStruct(MarkerStruct,  r.femur(1));   
        [RTH2] = datafromStruct(MarkerStruct,  r.femur(2));
        [RTH3] = datafromStruct(MarkerStruct,  r.femur(3));   

        [RTB1] = datafromStruct(MarkerStruct,  r.femur(1));   
        [RTB2] = datafromStruct(MarkerStruct,  r.femur(2));
        [RTB3] = datafromStruct(MarkerStruct,  r.femur(3));
           
        [LTH1] = datafromStruct(MarkerStruct,  l.femur(1));   
        [LTH2] = datafromStruct(MarkerStruct,  l.femur(2));
        [LTH3] = datafromStruct(MarkerStruct,  l.femur(3));   

        [LTB1] = datafromStruct(MarkerStruct,  l.femur(1));   
        [LTB2] = datafromStruct(MarkerStruct,  l.femur(2));
        [LTB3] = datafromStruct(MarkerStruct,  l.femur(3));
        
        [RCAL] = datafromStruct(MarkerStruct,  r.foot(1) ); % Right Lateral Mal
        [RMT1] = datafromStruct(MarkerStruct,  r.foot(2) ); % Right Medial Mal
        [RMT2] = datafromStruct(MarkerStruct,  r.foot(3) ); % Right Lateral Mal
        
        [LCAL] = datafromStruct(MarkerStruct,  l.foot(1)       ); % Left Cal
        [LMT1] = datafromStruct(MarkerStruct,  l.foot(2)       ); % Left big toe
        [LMT2] = datafromStruct(MarkerStruct,  l.foot(3)       ); % Left little toe

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
        G_LCAL=LCAL; G_RCAL(:,3)=0; 
        G_LMT1=LMT1; G_RMT1(:,3)=0;
        G_LMT2=LMT2; G_RMT2(:,3)=0;
        
        L_Midfoot= (LMT1+LMT2)/2;
        LG_Midfoot=(G_LMT1+G_LMT2)/2;
        
        
     % Calculate the Foot coordinate systems 
        [R_foot] = segmentsystem(RMT2,RMT1,R_Midfoot,RCAL,'zyx'); 
        [RG_foot] = segmentsystem(G_RMT2,G_RMT1,RG_Midfoot,G_RCAL,'zyx');
        
        [L_foot] = segmentsystem(LMT1,LMT2,L_Midfoot,LCAL,'zyx'); 
        [LG_foot] = segmentsystem(G_LMT1,G_LMT2,LG_Midfoot,G_LCAL,'zyx');
        
        Rfootoffset=jointangle(R_foot,RG_foot); Rfootoffset=mean(Rfootoffset(1:10,:));
        Lfootoffset=jointangle(L_foot,LG_foot); Lfootoffset=mean(Lfootoffset(1:10,:));

%% Calculate Joint angles between segment coordinate systems        
        
% Pelvis..........
    % Pitch(flexion), roll ( adduction) , yaw (rotation)
    % Since there isnt flexion adduction and rotation need to use these
    % terms
    PelvisAngle=jointangle(Global,pelvisSeg);
        Pelvis_Pitch=   mean(PelvisAngle(:,3));   
        Pelvis_roll=    mean(PelvisAngle(:,2));    
        Pelvis_yaw=     mean(PelvisAngle(:,1));    
% Trunk...........
        Trunk= -1*Pelvis_Pitch;  % NOt calculate but needed in OpenSim               
% Hip.............
    R_Hip=jointangle(pelvisSeg,R_femur);
        R.Hip_flexion=  mean(R_Hip(:,3));     
        R.Hip_Adduction=mean(R_Hip(:,1));       
        R.Hip_Rotation= mean(R_Hip(:,2));      
    
    L_Hip=jointangle(pelvisSeg,L_femur);
        L.Hip_flexion=  mean(L_Hip(:,3));       
        L.Hip_Adduction=-1*mean(L_Hip(:,1));      
        L.Hip_Rotation= -1*mean(L_Hip(:,2));     
% Knee............    
    R_Knee=jointangle(R_femur,R_tibia);
        R.Knee_flexion=  mean(R_Knee(:,3));   
        R.Knee_Adduction=mean(R_Knee(:,1));    
        R.Knee_Rotation= mean(R_Knee(:,2));     
           
    L_Knee=jointangle(L_femur,L_tibia);
         L.Knee_flexion=  mean(L_Knee(:,3));   
         L.Knee_Adduction=-1*mean(L_Knee(:,1));   
         L.Knee_Rotation= -1*mean(L_Knee(:,2));   
% Ankle...........
    R_Ankle=jointangle(R_tibia, R_foot);
         R.Ankle_flexion=  mean(R_Ankle(:,3));  
         R.Ankle_Inversion=mean(R_Ankle(:,1));  
         R.Ankle_Rotation= mean(R_Ankle(:,2)); 
    
    L_Ankle=jointangle(L_tibia, L_foot);
         L.Ankle_flexion=  mean(L_Ankle(:,3)); 
         L.Ankle_Inversion=mean(L_Ankle(:,1)); 
         L.Ankle_Rotation= mean(L_Ankle(:,2)); 



%%
profile off
profview  

%%
release( hEvStore );
release( hParamStore );
release( hTrial );
release( hServer );











