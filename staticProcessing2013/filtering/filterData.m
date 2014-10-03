function [ fdata ] = filterData(Fcut_butt,order,rate,data)
%   Runs a buttterworth filter on the data
%   Fcut_butt =     Cut off Frequency
%   Rate      =     Sampling frquency of the data
%   data      =     MxN matrix to be filtered

dt = 1/rate;
Fcut_butt = Fcut_butt /(sqrt(2) - 1)^(0.5/order);
Wn = 2 * Fcut_butt * dt;
[b, a] = butter(order, Wn);

    if isstruct(data)

       nMarkers = length(data);
       fdata = data;

       for i = 1:nMarkers

           [m n]=size(data(i).data);

               for ii=1:n
                    fdata(i).data = filtfilt(b, a, data(i).data);
               end

       end


    else

        [m n] = size(data);

        if n>1
            for ii=1:n
                fdata(:,ii) = filtfilt(b, a, data(:,ii));
            end
        elseif n==1
                fdata = filtfilt(b, a, data); %Tranpose Rows and Columns in Data
        end
    end
end
