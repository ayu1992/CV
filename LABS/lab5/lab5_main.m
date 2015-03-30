clear; close all; clc;
% CSci5561: Computer Vision
% Spring 2015
% Lab 5 - Homography

% - Steps:
% 1. Load the image
im = imread('flat_iron.jpg');
im = rgb2gray(im);
figure; hh = imshow(im);

% 2. Choos the point correspondences
% The corners of the building
p1 = [570 9 1]';
p2 = [505 376 1]';
p3 = [7 300 1]';
p4 = [251 54 1]';

% The new image borders
boxx = 3*285;
boxy = 3*190; 
pp1 = [boxx 1 1]';
pp2 = [boxx boxy 1]';
pp3 = [1 boxy 1]';
pp4 = [1 1 1]';

xs1 = [p1 p2 p3 p4];
xs2 = [pp1 pp2 pp3 pp4];

% Plot the point locations
figure; hh = imshow(im); hold on;
for i=1:4,
    plot(xs1(2,i), xs1(1, i), 'ro');
end

% 2. Compute the transformation matrix
% ---- TODO: Implement your function here ----- %
HH = zeros(3);
%HH = homography(xs2, xs1)
A(1,:) = [p1(1) p1(2) p1(3) 0 0 0 -p1(1)*pp1(1) -p1(2)*pp1(1)];
A(2,:) = [0 0 0 p1(1) p1(2) p1(3) -p1(1)*pp1(2) -p1(2)*pp1(2)];
A(3,:) = [p2(1) p2(2) p2(3) 0 0 0 -p2(1)*pp2(1) -p2(2)*pp2(1)];
A(4,:) = [0 0 0 p2(1) p2(2) p2(3) -p2(1)*pp2(2) -p2(2)*pp2(2)];
A(5,:) = [p3(1) p3(2) p3(3) 0 0 0 -p3(1)*pp3(1) -p3(2)*pp3(1)];
A(6,:) = [0 0 0 p3(1) p3(2) p3(3) -p3(1)*pp3(2) -p3(2)*pp3(2)];
A(7,:) = [p4(1) p4(2) p4(3) 0 0 0 -p4(1)*pp4(1) -p4(2)*pp4(1)];
A(8,:) = [0 0 0 p4(1) p4(2) p4(3) -p4(1)*pp4(2) -p4(2)*pp4(2)];

b = [pp1(1);pp1(2);pp2(1);pp2(2);pp3(1);pp3(2);pp4(1);pp4(2)];
HH = reshape([A\b;1],3,3)';
HH = inv(HH);
% 3. Apply image transformation 
% - Generate the points for all the pixels
[X, Y] = meshgrid(1:boxx, 1:boxy );
X = X(:)';
Y = Y(:)';
n = size(X, 2);
pts = [X; Y; ones(1, n)];
% - Allocate the new image 
newim = uint8(zeros(boxx+10, boxy+10));
% - Transform the points using the computed matrix
newpts = HH*pts;
newpts(1, :) = newpts(1, :) ./newpts(3, :);     % newpts(X,:)
newpts(2, :) = newpts(2, :) ./newpts(3, :);     % newpts(Y,:)
newpts(3, :) = newpts(3, :) ./newpts(3, :);     % newpts(Z,:)


% - Get the pixel value from the input image
for imI = 1:n,
    u = pts(1, imI); v = pts(2, imI); 
   uu = round(newpts(1, imI)); vv = round(newpts(2, imI)); 
   %% bonus : instead of simple rounding, use your bilinear interpolation code
    if uu > 0 && vv > 0, 
        newim(u, v) = im(uu,vv);
    end
end
figure; imshow(newim);
