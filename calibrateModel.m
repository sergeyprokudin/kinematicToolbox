function f = calibrateModel(varargin)


f = varargin;
return





for i = 1 : nargin
    
    % if input string is rotation, next value will be a rotation cell array
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'static'))

            functionInputs = varargin{i+1};
            % path 2 c3d file
            c3dFilePath = functionInputs{1};
            
            % Read in the marker data
            [PATH,NAME,EXT] = fileparts(c3dFilePath);
            structData = btk_loadc3d(fullfile(PATH,[NAME EXT]), 10);
            staticData = structData.marker_data.Markers; 
            
        end
    end
    
     % if input string is rotation, next value will be a rotation cell array
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'hipJoint'))
            % get a reference to the hip joint center intpus 
            hipJointInputs = varargin{i+1};
            % path 2 c3d file
            c3dFilePath = hipJointInputs{1};
            % marker names to use in analysis
            parentMkrs = hipJointInputs{2};
            childMkrs  = hipJointInputs{3};
            % Name of the output marker
            outputMkr  =  hipJointInputs{4};

            % Read in the marker data
            [PATH,NAME,EXT] = fileparts(c3dFilePath);
            display(['processing trial ' outputMkr ]);
            structData = btk_loadc3d(fullfile(PATH,[NAME EXT]), 10);
            mkrData = structData.marker_data.Markers; 
            
            % Generate the local frame of the pelvis
            if length(parentMkrs) == 4
                 mkrData =  stationBuilder(mkrData, parentMkrs, {'midPelvis' 'SACR'} );
                [frameOrigin, frameOrient] = frameBuilder(mkrData,{'midPelvis'}, {parentMkrs{1:2} 'SACR'}, 'v1v3' );
            elseif length(parentMkrs) == 3
                mkrData =  stationBuilder(data, parentMkrs(1:2), {'midPelvis'} );
                [frameOrient,frameOrigin] = frameBuilder(mkrData,{'midPelvis'}, parentMkrs, 'v1v3' );
            end
            
            
            newStations    = stationInFrame(mkrData,frameOrigin, frameOrient, childMkrs, 'local');
            
            Cm = sphericalFitting(newStations);
            CmG= repmat(Cm, length(newStations),1);
    
            [frameOrient,frameOrigin] = frameBuilder(staticData,{'midPelvis'}, parentMkrs, 'v1v3' );
            
            staticStation   = stationInFrame(staticData,frameOrigin, frameOrient, {CmG outputMkr}, 'global');

            eval(['staticData.' char(outputMkr) ' = staticStation;' ])
            stationInFrame(staticData, 
            
            
            
            
        
        end
    end

    
    % if input string is filter, next value will be a filter cell array
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'filter'))
               filterProp = varargin{i+1};
        end
    end
    % if input string is body, next value will be a body structure
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'body'))
               body = varargin{i+1};
               body.useBodies = 1;
        end
    end
    % if input string is mrkList, next value will be a array of strings
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'mrkList'))
               keepMkrs = varargin{i+1};
               useMkrList = 1;
        end
    end
end










 end