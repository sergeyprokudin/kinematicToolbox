function [frameOrigin, frameOrient] = frameBuilder(data, stationOrigin, stationFrame, v1v2v3)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%% calculate the frame origin
if length(stationOrigin)
    frameOrigin = data.(stationOrigin{1});
elseif length(stationOrigin) > 1
    frameOrigin = zeros(length(data.(mkrNames{1})),3);
    for i = 1:length(stationOrigin)
           frameOrigin = frameOrigin + data.(stationOrigin{i});
    end 
    frameOrigin = frameOrigin/i;
end

%% calculate the frame orientation
if strcmp('v1v2',v1v2v3)
        % Calculate the unit vectors using the V1V3 method.
        % frameOrient  = segmentorientationV2V1(LTCSmkr1-LTCSmkr3,LTCSmkr2-frameOrigin);
        frameOrient  = segmentorientationV2V1(data.(stationFrame{1})-data.(stationFrame{3}),data.(stationFrame{2})-frameOrigin);
        return
elseif strcmp('v1v3',v1v2v3)
        % Calculate the unit vectors using the V1V3 method.    
        % frameOrient  = segmentorientationV1V3(frameOrigin-LTCSmkr3, LTCSmkr1-LTCSmkr2);
        frameOrient  = segmentorientationV1V3(frameOrigin-data.(stationFrame{3}), data.(stationFrame{1})-data.(stationFrame{2}));
        return
else
        error(['input type ' v1v2v3 ' is not recognized'])
end



end

