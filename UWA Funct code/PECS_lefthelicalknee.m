%   PECS_lefthelicalknee.m
%   Calculate mean helical axis for left knee using PECS interface
[Nopt, Sopt, unitVectorArray, pivotPointArray] = meanhelicalaxis(LTH, LTB, 25, 'y', 2, 3, 1, 2, 2, VideoRate);

%   Scale helical axis vector
half_knee_width = 50;

%   Generate a helical axis vector
helical_axis_vector=(half_knee_width / Nopt(1)) * Nopt;
LKHA1 = Sopt - helical_axis_vector;
LKHA2 = Sopt + helical_axis_vector;


close;
