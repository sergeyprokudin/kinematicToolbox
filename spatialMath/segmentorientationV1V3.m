function frame = segmentorientationV1V3(V1,V3)
%% segmentorientationV1V3 calculates an orthoganal coordinate system.
%   segmentorientationV1V31() calculates an orthoganal Coordinate system 
%   from the crossproduct of unit vectors 1 and 3 to find vector 2. It then
%   calculates the crossproduct of Vector 1 and Vector 2 to find Vector 3. 

% create empty matrices for each
e1 = zeros(length(V1),3);
e2 = zeros(length(V1),3);
e3 = zeros(length(V1),3);

% Transform V1 and V3 into unit vectors
for i=1:length(V1)
   e1(i,:)=V1(i,:)/sqrt(dot(V1(i,:),V1(i,:)));
   e3(i,:)=V3(i,:)/sqrt(dot(V3(i,:),V3(i,:)));
end

% Crossproduct of e3 and e1 and transform to a unit vector (e2)
for i=1:length(V1)
   e2(i,:) = cross(e3(i,:),e1(i,:));
   e2(i,:) = e2(i,:)/sqrt(dot(e2(i,:),e2(i,:)));
end

% Crossproduct of e1 and e2 and to recalculate e3
for i=1:length(V1)
   e3(i,:) = cross(e1(i,:),e2(i,:));
end

frame = [e1 e2 e3];
