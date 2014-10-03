function [ output_args ] = createC3Dtrajectory(hTrial,label,data,First,Last)

[m n]=size(data);
if m>n
    data=data';
end


                hTrajectory = invoke(hTrial, 'CreateTrajectory');  
                set(hTrajectory,'Label',char(label));
                invoke(hTrajectory,'SetPoints',First,Last,data);
                release(hTrajectory);



               output_args=[char(label) ' printed successfully'];



end

















