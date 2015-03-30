% 1. Laplacian pyramid
close all;
cameraman = imread('cameraman.tif');
% build pyramid
pyramid = construct_pyramid(cameraman, 3, 4 ,4);
levels = size(pyramid,2);
figure;
for i = 1 : levels
    [n m] = size(pyramid{i});
    subplot(1, levels, i),
    imshow(uint8(pyramid{i}));title(sprintf('%d x %d', n, m));
end
saveas(gcf,'q1/1_Lpyramid.jpg');
% reconstruct image
reconstructed = reconstruct_image(pyramid);
figure;imshow(uint8(reconstructed));
saveas(gcf,'q1/1_Reconstructed.jpg');

psnr(double(reconstructed), double(cameraman))           %  = -15.8654

% 2. detect edges
close all;
figure;
% adjust parameter Thigh here
edge_image = detect_edges(cameraman, 5, 2, 0.8, 0.4);
subplot(1,2,1);imshow(uint8(edge_image));title('my Canny');
edge_bin = edge(cameraman,'canny');
subplot(1,2,2);imshow(edge_bin);title('built in Canny');
saveas(gcf,'q2/Final_Compare.jpg');

% 3. blob detection
close all;
% adjust line 5,10 and 16 inside detect_blobs.m, and then uncomment line 32
%circle_plotted = detect_blobs('circle');       
circles_plotted = detect_blobs('circles');
sunflower_plotted = detect_blobs('sunflower');

% 4. blending
or = imread('orange.jpg');
ap = imread('apple.jpg');
blended = blend_image(or,ap);
figure; imshow(uint8(blended));saveas(gcf,'q4/final.jpg');