function data =  stationBuilder(data, stations,outputStationName )

if length(stations)/2 ~= length(outputStationName)
    error('Number of stations needs to be twice the length as stationName')
end

u = 1;

for i = 1:2:length(stations)
    data.(outputStationName{u}) = ( data.(stations{i}) + data.(stations{i+1}) ) /2;
    u = u+1;
end



end