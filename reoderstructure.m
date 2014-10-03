function [temp_MarkerStruct] = reoderstructure(MarkerStruct,Markers)
%Reorders a data structure to that of a given list
% Used when order dependant analysis are required.
% MarkerStruct(uu).Name='LASI'
% Markers=[{'RASI'} {'LASI'} {'RPSI'} {'LPSI'} {'RTH1'} {'RTH2'} {'RTH3'}];





for ii=1:length(Markers)
        for uu=1:length(MarkerStruct)
           if strcmp(Markers(ii),char(MarkerStruct(uu).Name))==1
               tempstruct(ii)=MarkerStruct(uu);     %store the cells in list order
               MarkerStruct(uu)=[];                 %Delete the cell from the original structure
              break
           end
    
        end
end


temp_MarkerStruct=[tempstruct MarkerStruct];        %Slide in the the listed strucutre at the fron so all cells
                                                    % are kept but the ones
                                                    % in list order are at
                                                    % the front



end

