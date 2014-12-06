function frame = segmentorientationV2V1(V2,V1)
%% segmentorientationV2V1 calculates an orthoganal coordinate system.
%   segmentorientationV2V1() calculates an orthoganal Coordinate system 
%   from the crossproduct of unit vectors 2 and 1 to find vector 3. It then
%   calculates the crossproduct of Vector 2 and Vector 3 to find Vector 1. 

% create empty matrices for each
e1 = zeros(length(V1),3); 
e2 = zeros(length(V1),3);
e3 = zeros(length(V1),3);

% Transform V2 and V1 into unit vectors
for i=1:length(V1)
   e1(i,:)=V1(i,:)/sqrt(dot(V1(i,:),V1(i,:)));
   e2(i,:)=V2(i,:)/sqrt(dot(V2(i,:),V2(i,:)));
end

% Crossproduct of e1 and e2 and transform to a unit vector (e3)
for i=1:length(V1)
   e3(i,:) = cross(e1(i,:),e2(i,:));
   e3(i,:) = e3(i,:)/sqrt(dot(e3(i,:),e3(i,:))); 
end

% Crossproduct of e2 and e3 and to recalculate e1
for i=1:length(V1)
   e1(i,:) = cross(e2(i,:),e3(i,:));
end

frame = [e1 e2 e3];
