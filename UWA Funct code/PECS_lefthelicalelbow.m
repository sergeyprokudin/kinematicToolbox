%   PECS_lefthelicalelbow.m
%   Calculate mean helical axis for left elbow using PECS interface
[Nopt, Sopt, unitVectorArray, pivotPointArray] = meanhelicalaxis(iLUA, LFA, 25, 'y', 2, 3, 1, 2, 2, VideoRate);

%   Scale helical axis vector
half_elbow_width = 50;

%   Generate a helical axis vector
helical_axis_vector=(half_elbow_width / Nopt(1)) * Nopt;
LEHA1 = Sopt - helical_axis_vector;
LEHA2 = Sopt + helical_axis_vector;


close;

