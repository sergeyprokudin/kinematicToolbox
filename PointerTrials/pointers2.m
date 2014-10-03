% Pointers for condyle definition
    % trial_name= 'LLFC' or 'RMFC' or....
    % Assumed the pointer is labelled clockwise (-)
    % Author: James Dunne (dunne.jimmy@gmail.com)
    %          Massimo Satori
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


%% Create strucutre with all marker names in the trial 
     [MarkerStruct,trial_name, dat_path,analog_rate,sampleRate,First,Last] =  MarkerDataViaPecs(hTrial);

    
    
%% Define the necessary variables/labels

    %Negative(-355) was used because markers were labelled clockwise...
    %If markers that define plane are labelled anticlockwise, use +355. 
    pointerlength=-355;

if isempty(strfind(trial_name,'LLFC'))==0; 
        CondyleName={'LLFC'}; 
        Markers=[{'LTH1'} {'LTH2'} {'LTH3'}];
        columnNo=1;
end

if isempty(strfind(trial_name,'LMFC'))==0; 
         CondyleName={'LMFC'};
         Markers=[{'LTH1'} {'LTH2'} {'LTH3'}];
         columnNo=2;
end


if isempty(strfind(trial_name,'RLFC'))==0; 
         CondyleName={'RLFC'};
         Markers=[{'RTH1'} {'RTH2'} {'RTH3'}];
         columnNo=3;
end

if isempty(strfind(trial_name,'RMFC'))==0; 
         CondyleName={'RMFC'};
         Markers=[{'RTH1'} {'RTH2'} {'RTH3'}];
         columnNo=4;
end
    
%%	Reorder so the relevant markers are at the front
    [MarkerStruct] = reoderstructure(MarkerStruct,Markers);

%%  Push out the pointer markers
    PointerNames={'PNTR1' 'PNTR2' 'PNTR3' 'PNTR4' 'PNTR5'};
   
    [PNTR1] = datafromStruct(MarkerStruct,  PointerNames(1));   
    [PNTR2] = datafromStruct(MarkerStruct,  PointerNames(2));
    [PNTR3] = datafromStruct(MarkerStruct,  PointerNames(3));   
    [PNTR4] = datafromStruct(MarkerStruct,  PointerNames(4));
%    [PNTR5] = datafromStruct(MarkerStruct,  PointerNames(5));
    
%% Determine condyle position from markers
    %%%Written by Massimo Satori
        PNTRLength=length(PNTR1);
        Condyle=zeros(PNTRLength,3);
        meanPNTR=zeros(PNTRLength,3);
for i=1:PNTRLength(1)
    
    meanPNTR(i,1:3)=mean([[PNTR1(i,1) PNTR2(i,1) PNTR3(i,1) PNTR4(i,1)]' [PNTR1(i,2) PNTR2(i,2) PNTR3(i,2) PNTR4(i,2)]' [PNTR1(i,3) PNTR2(i,3) PNTR3(i,3) PNTR4(i,3)]']);
    normal1=-cross(PNTR1(i,1:3)-meanPNTR(i,1:3),PNTR2(i,1:3)-meanPNTR(i,1:3));
    normal2=-cross(PNTR4(i,1:3)-meanPNTR(i,1:3),PNTR1(i,1:3)-meanPNTR(i,1:3));
    normal3=-cross(PNTR3(i,1:3)-meanPNTR(i,1:3),PNTR4(i,1:3)-meanPNTR(i,1:3));
    normal4=-cross(PNTR3(i,1:3)-meanPNTR(i,1:3),PNTR2(i,1:3)-meanPNTR(i,1:3));
    normalmean=[(normal1+normal2+normal3+normal4)/4];
    
    
    normalmean=pointerlength*(normalmean/norm(normalmean));
    Condyle(i,1:3)=meanPNTR(i,1:3)+normalmean;    
        
end



%%  Place the Condlye data into the Storage Structure
    kk=length(MarkerStruct);
    MarkerStruct(kk+1) = struct('Name', {char(CondyleName)},'Data', {Condyle});

   
% Save Condile into the C3D File
    [output_args]=createC3Dtrajectory(hTrial,char(CondyleName),MarkerStruct(kk+1).Data,First,Last);

     
%% Place condile marker in the coordinate system of the parent segment%
    [VirtualMarker_TechCS] = MoveToTechnicalCS(MarkerStruct, Condyle);


%% Export to .vmc file   
    output_file = [char(dat_path) char(CondyleName) '.vpc'];
    
    fid = fopen(output_file,'w');
    fprintf(fid,'%f\n%f\n%f\n',VirtualMarker_TechCS) 
    fclose(fid);

 xlswrite([dat_path 'test.xls'],[2 3 4],'A','A1' )

%%

release( hEvStore );
release( hParamStore );
release( hTrial );
release( hServer );































