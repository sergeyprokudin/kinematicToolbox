function [e1,e2,e3] = segmentorientation(V1,V3)

e1 = zeros(length(V1),3);
e2 = zeros(length(V1),3);
e3 = zeros(length(V1),3);

for i=1:length(V1)
   e1(i,:)=V1(i,:)/sqrt(dot(V1(i,:),V1(i,:)));
   e3(i,:)=V3(i,:)/sqrt(dot(V3(i,:),V3(i,:)));
end

for i=1:length(V1)
   e2(i,:) = cross(e3(i,:),e1(i,:));
end

for i=1:length(V1)
   e3(i,:) = cross(e1(i,:),e2(i,:));
end
