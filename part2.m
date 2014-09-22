% the part 2, efficient graph-based image segmentation
% the input images are not the same dimensions, image2,3,4,5 are all RGB
% images, so we need to make a distinction here whether to convert the
% image into standard grey image
original_image = imread('segment_image5.bmp');

imagedimension = length(size(original_image));
% if the input image is a RGB image, we convert the image into a grey image
if imagedimension == 3
    image = rgb2gray(original_image);
else
    image = original_image;
end

imagesize = size(image);
% contruct a gaussian filter
g = fspecial('gaussian', [3 3], 0.8);
smooth_image = imfilter(image,g,'same');
figure;
imshow(smooth_image);
% calculate the weigh matrix
W = getW2(smooth_image);

% find location of the edges
location = find(W);
% get the value of edge weight according to their location
value = full(W(location));
% combine the location information with value information
locvalue = [location value];
% sort the edge weight
edges = sortrows(locvalue,2);
% get the edges sorting from high to low weight
edges = flipud(edges);

k = 10;
% the threshold(C) = k/|C|
T = length(edges);
% set the origin image label. each pixel is a separate label number
imagelabel = reshape(1:length(W),imagesize);
% set the initial threshold
threshold = ones(1,length(W))*k;
for i=1:T
    [p1 p2] = findInMatrix(W,edges(i,1));
    if (p1 ~= p2)
        if ((edges(i,2)<=threshold(p1)) && (edges(i,2)<=threshold(p2)))
            [imagelabel threshold]=join(p1,p2,edges(i,2),imagelabel,threshold,k);
        end
    end
end

im=imagelabel/max(max(imagelabel));
figure;
imshow(im);
figure;
imshow(label2rgb(imagelabel, @jet, [.5 .5 .5]))