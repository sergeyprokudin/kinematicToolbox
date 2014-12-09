function plotStations(data, stations, colors)

% data = staticData

for i = 1:length(stations)
    for u = 1 : length(stations{i})
    
    
    hold on
    
    scatter3(data.(stations{i}{u})(:,1),data.(stations{i}{u})(:,2),data.(stations{i}{u})(:,3)  ,char(colors{i}))
    
    end

end

    
    
    