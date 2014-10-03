function [tempstruct] = structureOutofStructure(MarkerStruct, Markers )
%Quick function for pulling data out of structure by searching through the
%names.

% 
tempstruct=MarkerStruct(1);
tempstruct(1)=[];

for ii=1:length(Markers)
        for uu=1:length(MarkerStruct)
           if strcmp(Markers(ii),char(MarkerStruct(uu).Name))==1
               tempstruct(1,ii)=MarkerStruct(uu);     %store the cells in list order
              break
           end
    
        end
end
