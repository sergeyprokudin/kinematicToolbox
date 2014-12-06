function [frameOrient,frameOrigin] = mkrs2Frame(Mkrs, v1v2v3)

% Break up the parent marker array into individual variables.
        LTCSmkr1 = Mkrs(:,1:3); 
        LTCSmkr2 = Mkrs(:,4:6); 
        LTCSmkr3 = Mkrs(:,7:9);
% Define the frameOrigin of the TCS markers as the midpoint between 
        frameOrigin=(LTCSmkr1+LTCSmkr2+LTCSmkr3 )/3;


if strcmp('v1v2',v1v2v3)
        % Calculate the unit vectors using the V1V3 method.
        [e1,e2,e3]  =   segmentorientationV2V1(LTCSmkr1-LTCSmkr3,LTCSmkr2-frameOrigin);
        frameOrient = [e1 e2 e3];
        return
elseif strcmp('v1v3',v1v2v3)
       % Calculate the unit vectors using the V1V3 method.    
        [e1,e2,e3]  =   segmentorientationV1V3(frameOrigin-LTCSmkr3, LTCSmkr1-LTCSmkr2);
        frameOrient = [e1 e2 e3];
        return
else
        error(['input type ' v1v2v3 ' is not recognized'])
end


end