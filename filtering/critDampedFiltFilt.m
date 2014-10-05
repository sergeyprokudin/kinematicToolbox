function [filteredData] = critDampedFiltFilt(N,Fcut,Fsp,data)

% Zero-lag Critically damped filter 
% Based on; "Design and responses of Butterworth and critically damped
% digital filters., D. Gordon E. Robertson, James J. Dowling. Journal of 
% Electromyography and Kinesiology 13 (2003) 569–573"
%%
% N           == The Number of Passes or the Order Number
% Fcut        == The Cut Off Frequency of the Signal
% InputData   == The Data to be Filtered
% Fsp         == The Sampling Frequency
%%
%   Written by James Dunne
%   Date:   June 2010
%   Modified by Samuel Hamner
%   Date:   September 2011
%%

%   Fcrit is the corrected cutoff frquency for the number of passes/order
    Ccrit = 1/sqrt(2^(1/(2*N))-1);
    Fcrit = Fcut * Ccrit;

% Wn the corrected angular cutoff frequency of the lowpass filter
    Wn= tan((pi*Fcrit)/Fsp);
    K1=2*Wn;
    K2=(Wn)^2;
% Critically Damped FIlter coeffecients become
    a0 = K2 / (1 + K1 + K2);
    a1 = 2 * a0;
    a2 = a0;
    b1 = 2*a0 * (1/K2 - 1);
    b2 = 1 - (a0 + a1 + a2 + b1);

if N>1
    for passes = 1 : N-1
        data = filtfilt([a0 a1 a2], [1 -b1 -b2], flipud(data));
    end
end

     filteredData = flipud(data);
    
end

