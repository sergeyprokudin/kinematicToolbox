function [ MarkerStruct ] = dataintoStruct(MarkerStruct,marker,data)
% UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


    Marker={marker};
    tempstruct=MarkerStruct(1);
    tempstruct.Name=char(marker);
    tempstruct.Data=data;
    
    m=length(MarkerStruct);
    
    
       i=0;
        for uu=1:m
           if strcmp(char(Marker),char(MarkerStruct(uu).Name))==1
                MarkerStruct(uu).Data=data;     %store the cells in list order
               break
           else
               i=i+1;
           end
        end

        if uu == m && i == uu
                MarkerStruct(m+1)= tempstruct
        end

end

