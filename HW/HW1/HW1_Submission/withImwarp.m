function I2 = withImwarp(I1, theta)
    d = theta*pi/180;
    img = imread(I1);
    [M,N] = size(img);
    T = [cos(d) -sin(d) 0;sin(d) cos(d) 0;0 0 1]
    tform = affine2d(T);
    I2 = imwarp(img,tform,'linear');
    figure(3);imshow(uint8(I2));colormap gray;
end