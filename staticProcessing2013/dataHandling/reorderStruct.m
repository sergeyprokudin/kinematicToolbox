function [temp_mkrStruct] = reorderStruct(mkrStruct,mkrNames)
%Orders a data structure from a given list
% Used when order dependant analysis are required.
% MarkerStruct(uu).Name     ='LASI'
% Markers                   =[{'RASI' 'LASI' 'RPSI'}];

% create a temporary structure that is the same length as the number of
% input mks.
tempstruct=mkrStruct(1:length(mkrNames));

if ischar(mkrNames)
    mkrNames = {mkrNames};
end


% for the length of the marker names
for i=1:length(mkrNames) 
% for the the lenght of the data stucture
    for u=1:length(mkrStruct)

           if strcmp(mkrNames(i),char(mkrStruct(u).name)) % Compare the string name given with the data string
               tempstruct(i) = mkrStruct(u);     %store the cells in list order
               mkrStruct(u)=[];                 %Delete the cell from the original structure
              break
           end
           
           % If we get to the end of the structure and nothing has been
           % been found then add the marker name to the index.
           if u == length(mkrStruct)
                temp_mkrStruct = [];
                return
           end
               
    end
end

% Recombine the ordered data strucutre with the remaining data struture
temp_mkrStruct=[tempstruct mkrStruct];        



end

