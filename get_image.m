%Reads an image and converts it to binary if possible

function [binaryImage, grayImage] = get_image(image_path)
% Load image from graphics file
OrigImage = imread(image_path);
% Depending on the format convert to grayscale
try
  grayImage  = rgb2gray(OrigImage);
catch
  grayImage = OrigImage;
end

% %Correct for all black pictures
% if mode(grayImage(:))==0
%     grayImage=~grayImage;
% end

%Histogram method with median
%binaryImage = logical(grayImage>median(grayImage(:)));

%Histogram method with mean
binaryImage = logical(grayImage>mean(grayImage(:)));

%Gaussian method
% mean_image=mean(double(grayImage(:)));
% std_var_image=std(double(grayImage(:)));
% binaryImage = logical(abs(double(grayImage)-mean_image)>0.5*std_var_image);

%Find white method (most common)
%  white_val=mode(grayImage(:));
%  white_width=20;
%  binaryImage = logical(grayImage>=(white_val-white_width)&grayImage<=(white_val+white_width));

end