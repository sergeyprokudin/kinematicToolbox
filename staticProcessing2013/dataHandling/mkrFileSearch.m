function [bodyMkrs mkrFileTree] = mkrFileSearch(mkrFileTree,tagName,dataIn)

% mkrFileTree           is a struture containing the 
% mkr               is a string defining the marker name ie 'LLFCpointer'
% data              ia a single frame vector             ie [21 13 -0.2]


  
%   If only the first two variables have been entered then the user is
%   making an enquiry. An enquiry returns associated names back in arrays
%   of strings and any data that may be associated with it. 

% check to see if the tagname is a string
if ~ischar(tagName)
    tagName=char(tagName);
end
% change to lower case
tagName = lower(tagName);

% find the number of bodies to search through
nBodies = length(mkrFileTree.bodySet.bodies);

% Preallocate some matrices
bodyName            = []; 
expMkrNames         = [];
virtMkrNames        = [];
data                = {};


% for each body
for i = 1:nBodies
        % dump the body name and make it lower case
        bodyName = lower((mkrFileTree.bodySet.bodies(i).ATTRIBUTE.name));
        % if tagName == a body then; 
        if strcmp(bodyName, tagName)
            % the body name
            bodyName        = (mkrFileTree.bodySet.bodies(i).ATTRIBUTE.name);
            % Experimental markers (array)
            % Virtual markers      (array)
            [bodyMkrs.expMkrs bodyMkrs.virMkrs]   = returnMkrNames(mkrFileTree, i);
            
            bodyMkrs.bodyName = bodyName;
        return 
        end
    
   
%% else search through the Experimental markers of the body (i)
    
    % Get a reference to the expMkr sub structure
    subStruct   =  mkrFileTree.bodySet.bodies(i).expMarkerSet;
    if ~isempty(subStruct) % check to see if there are exp Mkrs
        % Get a 'handle' to the expMarkerSet
        expMkrStruct   =  mkrFileTree.bodySet.bodies(i).expMarkerSet.expMarker;
        % Get the number of experimental markers on the body
        nExpMkr = length(expMkrStruct);

        for expMkrIndex = 1 : nExpMkr
             
            expMkrName = lower(expMkrStruct(expMkrIndex).name);

            % if tagName == the experimental marker name then; 
            if strcmp(expMkrName, tagName)

                % the body name
                bodyName = (mkrFileTree.bodySet.bodies(i).ATTRIBUTE.name);

                % Experimental markers (array)
                % Virtual markers      (array)
                [bodyMkrs.expMkrs bodyMkrs.virMkrs] = returnMkrNames(mkrFileTree, i);

                bodyMkrs.bodyName = bodyName;
                return
             end
        end    
    end       
%% else search through the virtual markers of the body (i)
    % Get a reference to the virtMkr sub structure
    subStruct   =  mkrFileTree.bodySet.bodies(i).virtMarkerSet;
    if ~isempty(subStruct) % check to see if there are virtual
        % Get a 'handle' to the virtMarkerSet
        virtMkrStruct   =  mkrFileTree.bodySet.bodies(i).virtMarkerSet.virtMarker;
        % Get the number of experimental markers on the body
        nVirtMkr = length(virtMkrStruct);

        for virtMkrIndex = 1 : nVirtMkr
             virtMkrName = lower(virtMkrStruct(virtMkrIndex).name);

            % if tagName == the virtual marker name then; 
            if strcmp(virtMkrName, tagName)

                % the body name
                bodyName = (mkrFileTree.bodySet.bodies(i).ATTRIBUTE.name);

                % Experimental markers (array)
                % Virtual markers      (array)
                [bodyMkrs.expMkrs bodyMkrs.virMkrs] = returnMkrNames(mkrFileTree, i);

                % and an empty data  []
                bodyMkrs.data = virtMkrStruct(virtMkrIndex).locationInTech;
                bodyMkrs.bodyName = bodyName;
    %% If 3 variables have been input, then the this should be data to write. use that data
    % to overide the virtual markers local TC's            
                if nargin == 3
                    % check to see if the data is an 1x3 matrix
                    [nRows nColm] = size(dataIn);
                    if (nRows*nColm) > 3; error('mkrFileSearch() data input is to large');end
                    if nRows>nColm; dataIn = dataIn'; end

                    % Save data to the variable
                    mkrFileTree.bodySet.bodies(i).virtMarkerSet.virtMarker(virtMkrIndex).locationInTech = dataIn;

                    % Output this variable to check that it done it correctly.
                    bodyMkrs.data = mkrFileTree.bodySet.bodies(i).virtMarkerSet.virtMarker(virtMkrIndex).locationInTech;
                    bodyMkrs.bodyName = bodyName;
                end

                return
            end
        end    
    end
   
end
%% If the function has gone all the way through and not found anything,
% evoke an error so that the user knows that the error is in this function.
error([char(tagName) ' was not found in file'])

    
end
    
  
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [expNameArray virtNameArray] = returnMkrNames(mkrFileTree, bodyIndex)
%%  returnMkrNames() returns an array of marker names for each. 
    % Get the array of mkrNames that belong to the body (strings) 
    
    expNameArray    = [];
    virtNameArray   = [];
    
    % Get a reference to the expMkr sub structure
    subStruct   =  mkrFileTree.bodySet.bodies(bodyIndex).expMarkerSet;
    % Get a reference to bodyname
    bodyName = lower((mkrFileTree.bodySet.bodies(bodyIndex).ATTRIBUTE.name));
    % check to see if there are expMkrs
    if ~isempty(subStruct) 
        % get a reference to the expMkr's
        subStruct   =  subStruct.expMarker;
        % get the number of expMkrs
        nMarkers    = length(subStruct);
        %Populate an array with the marker names
        for mKrIndex = 1: nMarkers
               expNameArray = [expNameArray {subStruct(mKrIndex).name}];
        end   
        
    else
        disp(['WARNING: No Experimental markers found for body: ' char(bodyName)])
        
    end
    
    % Get a reference to the virtMkr sub structure
    subStruct   =  mkrFileTree.bodySet.bodies(bodyIndex).virtMarkerSet;
    if ~isempty(subStruct) % check to see if there are virtual
        % get a reference to the virtMkr's
        subStruct   =  mkrFileTree.bodySet.bodies(bodyIndex).virtMarkerSet.virtMarker;
        % get the number of virtMkr's
        nMarkers    = length(subStruct);
        %Populate an array with the marker names
        for mKrIndex = 1: nMarkers
               virtNameArray = [virtNameArray {subStruct(mKrIndex).name}];
        end    
        
    else
        disp(['WARNING: No virtual markers found for body: ' char(bodyName)])
    end
end



















