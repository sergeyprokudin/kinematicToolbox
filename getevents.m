function [ EventTime  ] = getevents(hTrial,sampleRate)

 %% Determine if any events are in the c3d and if so use those to determine size of data
 
                        hEvStore = get( hTrial, 'EventStore' );
                        EventCount = invoke( hEvStore, 'EventCount' );
                        EventTime=[];
                       if  EventCount>0
                        
                            for Index = 0:(EventCount - 1)
                                    hTempEvent = invoke( hEvStore, 'Event', Index );
                                    hTempContext = invoke( hTempEvent, 'Context' );
                                    Label = invoke( hTempContext, 'Label' );
                                    IconID = invoke( hTempEvent, 'IconID' );
                                    Time = invoke( hTempEvent, 'Time' );
                                    frame=Time*sampleRate;
                                    EventTime=[EventTime frame];
                                    
                            end

                       end
end

