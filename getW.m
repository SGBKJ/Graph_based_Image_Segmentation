% this function generates the weight matrix
% the inputs are: image,mask,sigma1,sigmax
% the outputs are weight matrix W
function W = getW(image,mask,sigma1,sigmax)
r = 5;
[height, width] = size(image); 
OnesinMask = length(find(mask == 1));

Image2 = zeros(height+2*r, width+2*r);
Image2(r+1:height+r,r+1:width+r) = image;

ImageAfterTravel = im2col(Image2,[2*r+1 2*r+1],'sliding');
CentralPoints = ImageAfterTravel(round((2*r+1)^2/2),:);
CentralPointsRep = repmat(CentralPoints,(2*r+1)^2,1);

% calculate the part1 of the equation(11)
ValueResult = exp(-(ImageAfterTravel-CentralPointsRep).^2/(sigma1^2));
% calculate the coordinates
X = repmat([1:2*r+1]',1,2*r+1);
Y = repmat([1:2*r+1],2*r+1,1);

% calculate the part2 of the equation(11)
distance = (X-(r+1)).^2+(Y-(r+1)).^2;
part2 = exp(-distance/(sigmax^2));
part2Vector = reshape(part2,[],1);
part2Matrix = repmat(part2Vector,1,height*width);

% multiply part1 and part2 into the whole result
ValueResult = ValueResult.*part2Matrix;

% deal with the index
% index = [1:height*width];
index = zeros(1,height*width);
index(mask==1) = [1:OnesinMask];
indexMatrix = reshape(index,height,width);
indexMatrix2 = zeros(height+2*r, width+2*r);
indexMatrix2(r+1:height+r,r+1:width+r) = indexMatrix;
IndexAfterTravel = im2col(indexMatrix2,[2*r+1 2*r+1],'sliding');
CentralIndex = IndexAfterTravel(round((2*r+1)^2/2),:);
CentralIndexRep = repmat(CentralIndex,(2*r+1)^2,1);

% adding mask
IndexAfterTravel = IndexAfterTravel(:,mask == 1);
CentralIndexRep = CentralIndexRep(:,mask == 1);
ValueResult = ValueResult(:,mask == 1);

% X index
IndexAfterTravelVector = reshape(IndexAfterTravel,[],1);
% IndexAfterTravelVector(IndexAfterTravelVector==0) = (height*width)^2+1;
% Y index
CentralIndexRepVector = reshape(CentralIndexRep,[],1);
ValueResultVector = reshape(ValueResult,[],1);

%remove the zero coordinates
CentralIndexRepVector(IndexAfterTravelVector==0) = 1;
IndexAfterTravelVector(IndexAfterTravelVector==0) = 1;

W = sparse(IndexAfterTravelVector,CentralIndexRepVector,ValueResultVector,OnesinMask,OnesinMask);
W(1,1) = 1;

end