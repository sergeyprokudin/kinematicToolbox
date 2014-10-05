function [ data ] = accessStructData(mkrStruct,mkrNames,mkrData)
% data2Struct() gets and sets maker data between arrays and a structure
%   This function takes a marker structure and searches through it to find
%   the marker 'mkrNames'. When data is input as the third variable the
%   fucntion either replaces existing data or adds new data to the end of
%   strucutre.
%
%   
%
%
%   mkrStruct   =   A structure of marker data with marker names
%                   mkrStruct.name = 'RASI' & mkrStruct.data = nX3 matrix
%   mkrNames    =   A character array of strings {'RASI' 'LASI'}. Can be
%                   individual string mkrNames = 'RTH1'
%   mkrData     =   Marker Data array to be stored into structure. Is an
%                   nx(3*m) matrix where m = the number of mkrNames

    
%% Check if variable entered as mkrStruct is actually a structure
    if isstruct(mkrStruct)
        nMkrs       = length(mkrStruct);
    else
        error('First variable in dataintoStruct is not a mkr strucutre')
    end
        
%% Check if variable entered as mkrNames is correct format   
    if ischar(mkrNames)    % check to see if it is a string
        % Sert the length to 1
        nMkrNames   = 1;
        % Change to cell type
        mkrNames   = {mkrNames};
    elseif iscell(mkrNames) % check to see if it is a cell array
        nMkrNames   = length(mkrNames); 
    else
        error('mkrNames is of wrong data type')
    end
            
            
%% user wants to 'get' data out of structure
    if nargin == 2 
        % Take the the mkrName(s) and search the structure, returning each
        % found mkrName's data into an array. There is an assumption that 
        % the user is putting the correct names. Incorrect names will
        % return an error
     
    data     = [];
    mkrIndex =  0 ;
        for i = 1: nMkrNames
        
            for u = 1: nMkrs
        
                if  strcmp( mkrNames(i) , char(mkrStruct(u).name))
                        
                    
                    if isempty(data) % The first mkrName
                       % get the size of the current marker. nRowMkr1 is
                       % designated as the 'biggest' number of rows. In
                       % this case there is only 1 mkr. For multiple
                       % markers this number would only increase. 
                       [nRowMkr1 nColmMkr1] =  size(mkrStruct(u).data);
                       % dump out the marker data
                       data = mkrStruct(u).data;  
                     
                    else
                        % This is the nth marker output from this loop.
                        % Get the size of the current mkrData
                        [nRowMkr2 nColmMkr2] =  size(mkrStruct(u).data);
                        
                        % case1
                        if nRowMkr1 ==  nRowMkr2
                           % Append coloumns to data
                           data = [data mkrStruct(u).data];
                        end
                        
                        % case2 nRowMkr2 < nRowMkr1
                        if  nRowMkr2 < nRowMkr1
                            % Append 'zeros' to the data to equate the
                            % number of rows
                            tempData = [mkrStruct(u).data; zeros(nRowMkr1-nRowMkr2, 3 )];
                            % Append coloumns to data
                            data = [data tempData];
                        end
                        
                        % case3 nRowMkr1 < nRowMkr2
                        if nRowMkr1 < nRowMkr2
                           % Get the size of the current array
                           [m nColmArray] = size(data);
                           % Append 'zeros' to the storage array to equate 
                           % the number of rows
                           data =  [data; zeros(nRowMkr2-nRowMkr1, nColmArray )];
                           % Append coloumns to data
                           data = [data mkrStruct(u).data];
                           % Update to the largest nRows 
                           nRowMkr1 = nRowMkr2; 
                        end
                           
                    end
                    % Stop searching for this nkrName and move onto the 
                    % next one. add 1 to the index to show that it has
                    % been computed
                    mkrIndex = mkrIndex + 1 ;
                    break
                end    
            end
        end
        
        % This catches if there has been any mkrnames not found in the
        % structure.  
        if mkrIndex == 0 || mkrIndex < nMkrNames
           error('mkrNames dont exist. Check input strings to structure')
        end    
   
    end
    
%% user wants to 'set' data to the structure    
    if nargin == 3 
         % Check for the size of the mkrData array and make sure its the
         % same size as the number of mkr's
         [nRowMkr nColmMkr] =  size(mkrData);
         % nColmMkr divided by nMkrNames should = 3 
         if ~((nColmMkr/nMkrNames) == 3)
              error('number of mrkNames doesnt match the number of input data colomns')
         end
        
         
         % Sort each label name into 1 of 2 catergories. Either the label
         % name is already in the strucutre or it isnt. 
         
         InStruct           = [];
         InStructData       = [];
         NotInStruct        = [];
         NotInStructData    = [];
         structIndex        = [];
         
         
         for i = 1: nMkrNames
             % Set the default for marker to false
             isInStruct = false ;
             
             % If the label name is found change to 'true'
             for u = 1: nMkrs
                 if  strcmp( mkrNames(i) , char(mkrStruct(u).name))
                     % If string names match, change to true
                     isInStruct = true;
                     structIndex = [structIndex u];
                     break
                 end
             end
             
             if isInStruct 
                InStruct     = [InStruct mkrNames(i)];
                InStructData = [InStructData mkrData(:,(3*i)-2:(3*i))];
             else
                NotInStruct     = [NotInStruct mkrNames(i)]; 
                NotInStructData = [NotInStructData mkrData(:,(3*i)-2:(3*i))];
             end    
                 
         end
         
        % Know that we have sorted the label names given their existence in 
        % the strucutre, either replace or append into the structure. 
        
        % if any of th labels already exist, replace the data
        if ~isempty(InStruct) 
                % For each label in the structure, update the data
                for i = 1:length(InStruct)
                    % All we need to do is update the data. Use structIndex
                    % to get a reference to the mkr in the structure. 
                    mkrStruct(structIndex(i)).data = InStructData(:,(3*i)-2:(3*i));
                end
         end     
             
         % if any of the labels dont exist, append a cell to the structure 
         if ~isempty(NotInStruct) 
             % For each mkr that doesnt exist in the structure, append
             % the mkrName, and the data to the end of the current
             % structure. 
             for i = 1:length(NotInStruct)
                % Group the data and name into a structure  
                tempStruct = struct('name',{char(NotInStruct(i))},'data',{NotInStructData(:,(3*i)-2:(3*i))});
             
                % Append the data the currect structure
                mkrStruct = [mkrStruct tempStruct];
              end
         end
         
         % Change the name of the structure for the output 
         data = mkrStruct;
         
         
     end


end

