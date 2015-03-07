Name: An An Yu
ID:       5116372
email:  yuxx0535@umn.edu


Code execution 
Run in console:


clear all;
close all;
img = imread('onion.png');
figure(1);imshow(img);title('Task 2');
intensity = rgb2gray(img);
figure(2);imshow(intensity);title('Task 3');
imdouble = im2double(intensity);
figure(3);imshow(imdouble);title('Task 4 im2double');
doub = double(intensity); % shredded
figure(4);imshow(doub./255);title('Task 4 double');
cropped = Crop(intensity,5,5,50,70);
figure(5);imshow(cropped);title('Task 5');
% manually set window size
win_size = 3;
out = Blur(imdouble,win_size);
figure(6);imshow(out);title('Task 6 - my conv');
figure(7);imshow(conv2(imdouble,ones(win_size,win_size))./(win_size^2));title('Task 6 - conv2()');