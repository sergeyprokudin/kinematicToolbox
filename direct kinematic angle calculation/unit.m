function [unitvector]=unit(vector,dim)

  [r c] = size(vector);
    %Convert the vector to columns
    if (c<3 && r==3); 
        vector = vector';
    end
     [r c] = size(vector);
    %Process the unit transform
    
    for ii=1:r
     unitvector(ii,:)=vector(ii,:)./norm(vector(ii,:));
    end
    
    if not(sqrt(sum(unitvector(1,:).^2)) < 1.00001) && not(sqrt(sum(unitvector(1,:).^2)) > 0.99999)
        error(['There has been a calculation error, because the square root of the sum of the squares does not equal 1']);
    end

end