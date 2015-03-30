clear; close all; clc;

%%%%% parameters %%%%

% for image gradient
sigma_gradient = 0.7;
winsz_gradient = 5;

% for Harris corner
sigma_corner = 1;
winsz_corner = 5;
k_corner = 0.1;

% for thresholding
thres_corner = 3;

% for non-maximum suppression
winsz_suppres = 7;


%%%%% read image %%%%%
im_in = imread('flat_iron.jpg');
[N M] = size(im_in);
im_in = rgb2gray(im_in);


%%%%% STEP 1: compute image gradients with Gaussian smoothing %%%%%
% generate Gaussian kernel
G = fspecial('Gaussian', [5 5], 0.7);
% smooth the image
im_smoothed = conv2(im_in, G, 'same');
% plot the smoothed image
figure; imshow(uint8(im_smoothed)); savefig('1-Smoothed.fig');
% compute image gradient along x: Ix
Ix = conv2(im_smoothed, [-1, 0, 1], 'same');
% compute image gradient along y: Iy
Iy = conv2(im_smoothed, [-1; 0; 1], 'same');
% plot the gradient images
figure; imshow(uint8(Ix));  savefig('1-Ix.fig');
figure; imshow(uint8(Iy));  savefig('1-Iy.fig');
%%%%% STEP 2: compute Harris cornerness values %%%%%
corners_values = cornerness(Ix, Iy, sigma_corner, winsz_corner, k_corner);

%%%%% STEP 3: thresholding %%%%%

corners_thres = thresholding(corners_values, thres_corner);

%%%%% STEP 4: non-maxima suppression %%%%%
corners_thres_max = suppressNonMaxima(corners_thres, winsz_suppres);

%%%%% plot corners onto image %%%%%
% plot corners
[indI, indJ] = find(corners_thres_max > 0);
figure; hh = imshow(im_in);savefig('5-Final.fig');
hold on;
plot(indJ, indI, 'x r');