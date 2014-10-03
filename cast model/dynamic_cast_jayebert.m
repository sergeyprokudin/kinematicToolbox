
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


%% Interact with the PECS server to pull create a structure %%

[MarkerStruct,trial_name, dat_path,analog_rate,sampleRate,First,Last] =  MarkerDataViaPecs(hTrial);

% Event time used
[ EventTime  ] = getevents(hTrial,sampleRate);

%% Filter the data
filt_MarkerStruct=MarkerStruct;
Fcut=8;
for ii=1:length(MarkerStruct)
            filt_MarkerStruct(ii).Data= filterData(Fcut,sampleRate,MarkerStruct(ii).Data);
end

%% functional analysis?
    fun=1;
%% Define the segment/joint dependencies (labels)

    %Trunk
        trunk ={'C7' 'T10' 'CLAV' 'STRN'};
    %Pelvis
        Pelvis ={'LASI' 'RASI' 'LPSI' 'RPSI'};
    % Define markers for each segment
        r.femur= {'RTH1' 'RTH2' 'RTH3'};
        r.tibia= {'RTB1' 'RTB2' 'RTB3'};
    
        l.femur= {'LTH1a' 'LTH2a' 'LTH3a'};
        l.tibia= {'LTB1' 'LTB2' 'LTB3'};

        r.foot=[{'RCAL'} {'RMT1'} {'RMT5'}];
        l.foot=[{'LCAL'} {'LMT1'} {'LMT5'}];
    
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
    mpfile=dir('*cast.txt'); % find all the functional joint files
    filepath=[dat_path mpfile.name];
    mpdata = importdata(filepath);

     for ii=1:length(mpdata.textdata)
             eval([ char(mpdata.textdata(ii)) '= mpdata.data(ii,:)']);
     end
         
 
%% Dump markers into the workspace

        [LASI] = datafromStruct(MarkerStruct, Pelvis(1) ); % Left Anterior
        [RASI] = datafromStruct(MarkerStruct, Pelvis(2) ); % Right Anterior
        [LPSI] = datafromStruct(MarkerStruct, Pelvis(3) ); % Left Posterior
        [RPSI] = datafromStruct(MarkerStruct, Pelvis(4) ); % Right Posterior
        [SACR]  = (LPSI+RPSI)/2;
        [MidPEL]= (LASI+RASI)/2;
        [Opelvis]= MidPEL;

        [LTH1] = datafromStruct(MarkerStruct, l.femur(1) ); % Left Anterior
        [LTH2] = datafromStruct(MarkerStruct, l.femur(2) ); % Right Anterior
        [LTH3] = datafromStruct(MarkerStruct, l.femur(3) ); % Left Posterior
        
        [RTH1] = datafromStruct(MarkerStruct, r.femur(1) ); % Left Anterior
        [RTH2] = datafromStruct(MarkerStruct, r.femur(2) ); % Right Anterior
        [RTH3] = datafromStruct(MarkerStruct, r.femur(3) ); % Left Posterior
        
        [LTB1] = datafromStruct(MarkerStruct, l.tibia(1) ); % Left Anterior
        [LTB2] = datafromStruct(MarkerStruct, l.tibia(2) ); % Right Anterior
        [LTB3] = datafromStruct(MarkerStruct, l.tibia(3) ); % Left Posterior
        
        [RTB1] = datafromStruct(MarkerStruct, r.tibia(1) ); % Left Anterior
        [RTB2] = datafromStruct(MarkerStruct, r.tibia(2) ); % Right Anterior
        [RTB3] = datafromStruct(MarkerStruct, r.tibia(3) ); % Left Posterior
        
        % Segment Markers  
    
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
       
        
        

%%
release( hEvStore );
release( hParamStore );
release( hTrial );
release( hServer );










