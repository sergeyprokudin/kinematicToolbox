function [Rx]=rotx(q)

% Return a 3x3 rotation matrix that rotates a 3x1 vector by q radians
%    about the x axis (dimension 0).
Rx=[cos(q)  0        sin(q);...
    0       1        0;...
    sin(q)  0   cos(q)];








