function [Rz]=rotz(q)

% Return a 3x3 rotation matrix that rotates a 3x1 vector by q radians
%    about the x axis (dimension 0).
Rz=[cos(q)  -sin(q)  0;...
    sin(q)  cos(q)   0;...
    0       0        1];








