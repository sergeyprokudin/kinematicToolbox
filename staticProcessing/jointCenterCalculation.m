function staticData = jointCenterCalculation(varargin)

% staticData = varargin;
% return


for i = 1 : nargin
    
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'static'))

            functionInputs = varargin{i+1};
            % path 2 c3d file
            c3dFilePath = functionInputs{1};
            % Read in the marker data
            structTrial = btk_loadc3d(c3dFilePath, 10);
            
            staticData = structTrial.marker_data.Markers; 
            staticData = rotateCoordinateSys(staticData,varargin{2});
            
            % stations = {{'R_TH1'  'R_TH2' 'R_TH3'} {'R_ASIS' 'R_PSIS'} {'L_ASIS'  'L_PSIS'}}   ;
            % colors = {'b' 'g' 'k'};
            % plotStations(staticData, stations, colors)

            
        end
    end
    
    
   if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'sphericalFit'))
            
            functionInputs = varargin{i+1};
            c3dFilePath = functionInputs{1};
            % marker names to use in analysis
            parentMkrs = functionInputs{2};
            childMkrs  = functionInputs{3};
            % Name of the output marker
            outputMkr  =  functionInputs{4};

            % Read in the marker data
            mkrData = btk_loadc3d(c3dFilePath, 10);
            mkrData = mkrData.marker_data.Markers; 
            mkrData = rotateCoordinateSys(mkrData,varargin{2});

%             plotStations(mkrData, stations, colors)
            
            % get a reference to the hip joint center intpus 
            staticData = sphericalFittingHelper(staticData,mkrData,parentMkrs,childMkrs,outputMkr);
             
%             stations = {{'R_TH1'  'R_TH2' 'R_TH3'} {'R_ASIS' 'R_PSIS'} {'midPelvis' 'SACR'} {'L_ASIS'  'L_PSIS'} {'RHJC'}}   ;
%             colors = {'b' 'g' 'k' 'c' 'r'};
%             plotStations(staticData, stations, colors)
        end
   end

    
    
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'helicalKnee'))
               filterProp = varargin{i+1};
        end
    end
   
    
    
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'anatomicalJoint'))
                
                % Read in the marker data
                functionInputs = varargin{i+1};
                c3dFilePath = functionInputs{1};
                mkrData = btk_loadc3d(c3dFilePath, 10);
                mkrData = mkrData.marker_data.Markers; 
                mkrData = rotateCoordinateSys(mkrData,varargin{2});
                % get the joint and ouput station names. 
                parentMkrs =  functionInputs{2};
                outputMkr  =  functionInputs{3};
                
                mkrData  =  stationBuilder(mkrData, parentMkrs, outputMkr );
               
                eval(['staticData.' char(outputMkr) ' = mkrData.' char(outputMkr) ';' ]);
        end
    end
    
    
     
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'createFeet'))
                
                % Read in the marker data
                functionInputs = varargin{i+1};
               
                for u = 1 : length(functionInputs)
                    
                     data      = staticData.(functionInputs{u});
                     data(:,2) = 0;
                     
                     eval(['staticData.' [functionInputs{u} '_grd' ] ' = data ;' ]);
                end
        end
    end
    
end
    
    



% Print the structData into a OpenSim trc format 
printTRC(staticData,...         % Markers
     structTrial.marker_data.Info.frequency,...  % video freq
     structTrial.marker_data.Filename);          % filename

 end