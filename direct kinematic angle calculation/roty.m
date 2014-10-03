function [Ry]=roty(q)

% Return a 3x3 rotation matrix that rotates a 3x1 vector by q radians
%    about the x axis (dimension 0).
Ry=[cos(q)  0        sin(q);...
    0       1        0;...
    sin(q)  0        cos(q)];








