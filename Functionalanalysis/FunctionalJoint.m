% Functional code for Ball Joint and Helical Axis calculation 
    % Defines Marker names and data, runs analysis and prints Joint
    % center/axes locations to file
    % Type of analysis is determined by string in trial name
    % 'FunHip','FunKnee'
    % Assumed that hip and Knee for both legs is collected in the same
    % trial.
    % Author:  James Dunne (dunne.jimmy@gmail.com)
    %          Thor Besier
    %          Cyril J Donnelly
    % Created: Janurary 2010
    % Updated: April 2012


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


%% Create structure with all marker names in the trial 

[MarkerStruct,trial_name, dat_path,analog_rate,sampleRate,First,Last] =  MarkerDataViaPecs(hTrial);

% Event time used to workout left and right hip swingers. Place 1 general 
% event marker inbetween right and left motions.
[ EventTime  ] = getevents(hTrial,sampleRate);

%% Specifiy variables based on trial type (hip, knee, ankle)
        
    % Hip swingers
        if isempty(strfind(trial_name,'unHip'))==0;
                 Markers=[{'RASI'} {'LASI'} {'RPSI'} {'LPSI'} {'LTH1'} {'LTH2'} {'LTH3'} {'RTH1'} {'RTH2'} {'RTH3'}];
                 trial_type='HJC';
                 FunctionalTrialName='FunHip';
                 Helicalaxis='n';
                 Balljoint='y';
                 SacrCheck='SACR';  
                 denote=[];
        end
        
    % Knee swingers
        if isempty(strfind(trial_name,'unKnee'))==0;
                 Markers=[{'LTH1'} {'LTH2'} {'LTH3'} {'LTB1'} {'LTB2'} {'LTB3'} {'RTH1'} {'RTH2'} {'RTH3'} {'RTB1'}...
                     {'RTB2'} {'RTB3'}];
                 Axis=[{'LLFC'} {'LMFC'} {'RLFC'} {'RMFC'}];
                 trial_type='KJC';
                 FunctionalTrialName='FunKee';
                 Helicalaxis='y';
                 Balljoint='n';
        end
        
    % Ankle swingers
        if isempty(strfind(trial_name,'unAnkle'))==0;
                 Markers=[{'LTB1'} {'LTB2'} {'LTB3'} {'LMT1'} {'LMT2'} {'LCAL'}...
                     {'RTB1'} {'RTB2'} {'RTB3'} {'RMT1'} {'RMT2'} {'RCAL'}];
                 Axis=[{'LLFC'} {'LMFC'} {'RLFC'} {'RMFC'}];
                 trial_type='AJC';
                 FunctionalTrialName='FunAnkle';
                 Helicalaxis='y';
                 Balljoint='n';
        end


%% filter the marker data using a butterworth filter   
    % Frequency cutoff
        Fcut_butt=8;        
    % Rename the data matrix
        Filt_MarkerStruct=MarkerStruct;
        nMarkers=length(MarkerStruct);
    % Filter each marker
        for i=1:nMarkers
                Filt_MarkerStruct(i).Data = filterData(Fcut_butt,sampleRate,MarkerStruct(i).Data);
        end

        
        %         data=MarkerStruct(i).Data(:,1);
        %         N       =20;
        %         fre_cut = [6 8 10 12 14];
        %         fre_sp  = analog_rate   ;
        %         
        %         residualanalysis(data,N,fre_cut,fre_sp)
        %         
%% Reorder markers so they correspond with order in 'Markers'
        [Filt_MarkerStruct] = reoderstructure(Filt_MarkerStruct,Markers);     
  

%%  Conduct the functional analysis for specific joint type(Ball joint or Helical)%
if strcmp(Helicalaxis,'y')==1 %Check if Helical Axis Calculation
        [JointAxes,NewAxisLabels] = HelicalAxisSort(Filt_MarkerStruct,trial_type,sampleRate);
   
elseif strcmp(Balljoint,'y')==1  % Swinger with both legs in same trial
       
        [JointAxes,NewAxisLabels] = BallJointSort(Filt_MarkerStruct,trial_type,trial_type,EventTime);
end

%% print to file
       
output_file = [dat_path char(trial_type) '.fjc'];
fid = fopen(output_file,'w');
[m n]=size(JointAxes);

% Print headers
for ii=1:n
     fprintf(fid,'%s\t%s\t',char(NewAxisLabels(ii)));
end
     fprintf(fid,'\n');
% Print data
for ii=1:m
       fprintf(fid,'%f\t',JointAxes(ii,:));
        fprintf(fid,'\n');
end
fclose(fid);       

    
release( hEvStore );
release( hParamStore );
release( hTrial );
release( hServer );



