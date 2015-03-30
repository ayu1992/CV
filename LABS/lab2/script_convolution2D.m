n = 3;
sigma = 0.1;
img = imread('cameraman.tif');
cir = imread('circuit.tif');
h1 = ones(n,n)/(n^2);
f1 = figure(1);surf(h1);saveas(f1, 'avgKernel_n=3.tif');
k1 = conv2(img,h1);
f2 = figure(2);imshow(uint8(k1));saveas(f2, 'blur_avgKernel_n=3.tif');

h2 = fspecial('Gaussian', n, sigma);
f3 = figure(3);surf(h2); saveas(f3, 'gauKernel_n=3_sigma=0.1.tif');
k2 = conv2(img,h2);
f4 = figure(4);imshow(uint8(k2));saveas(f4, 'blur_gauKernel_n=3_sigma=0.1.tif');

hsx = [-1 0 1; -2 0 2; -1 0 1];
hsy = [-1 -2 -1; 0 0 0; 1 2 1];
f5 = figure(5);surf(hsx); saveas(f5, 'sobel_hx.tif');
f6 = figure(6);surf(hsy); saveas(f6, 'sobel_hy.tif');
gx = conv2(cir, hsx);
f7 = figure(7); imshow(uint8(gx)); saveas(f7, 'Gx.tif');
gy = conv2(cir,hsy);
f8 = figure(8); imshow(uint8(gy)); saveas(f8,'Gy.tif')
