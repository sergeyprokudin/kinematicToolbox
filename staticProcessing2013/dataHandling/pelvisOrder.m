function [parentMkrStruct] = pelvisOrder(mkrStruct,parentMkrNames)

        % Order the pelvis in the structure
        parentStruct                = reorderStruct(mkrStruct, parentMkrNames );
        % Calculatre the position of the Sacrum using the 2 PSIS markers
        Sacr                        = (parentStruct(3).data + parentStruct(4).data)/2;
        % Add SACR to a copy of the fitered data. Just overwrite one of the
        % PSIS markers as they are not used in the analysis.
        parentStructCopy            = parentStruct;
        parentStructCopy(3).data    = Sacr;
        parentStructCopy(3).name    = 'SACR';
        parentMkrNames(3)          = {'SACR'};
        % Reoder the pelvis (parent) structure. Use this struture going forward
        parentMkrStruct  = reorderStruct(parentStructCopy, parentMkrNames(1:3) );

end

















