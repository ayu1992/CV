% rotate_image.m
%
% This function takes in an image I1 and rotates it with 
% theta degrees (counter-clock wise) by the point po, using 
% the minimal padding.
%
% An An Yu, yuxx0535@umn.edu
% Feb 1, 2015

function I2 = rotate_image(I1, theta, po)
% rotate image I1 with theta degrees by the point po
d = theta*pi/180;
img = imread(I1);
[M,N] = size(img);
R = [cos(d),-sin(d);sin(d),cos(d)];

% Calculate rotated image size
pcr1 = R * ([0 0]' - po);
pcr2 = R * ([M 0]' - po);
pcr3 = R * ([M N]' - po);
pcr4 = R * ([0 N]' - po);

nM = max(abs(ceil(pcr1(1) - pcr3(1))), abs(ceil(pcr2(1) - pcr4(1))));
nN = max(abs(ceil(pcr1(2) - pcr3(2))), abs(ceil(pcr2(2) - pcr4(2))));
I2 = zeros(nM,nN);
pf = [-min([pcr1(1),pcr2(1),pcr3(1),pcr4(1)]); -min([pcr1(2),pcr2(2),pcr3(2),pcr4(2)])];
% for every pixel in I2, reverse mapping
for x = 1 : nM
    for y = 1 : nN
        oriCoords = po + inv(R)*([x y]' - pf);
        coords = floor(oriCoords);
        n1 = coords(1);
        n2 = coords(2);
        a = oriCoords(1) - n1;
        b = oriCoords(2) - n2;
        % check out of bounds
        if (n1 >= 1) && (n1 <= M - 1) && (n2 >= 2) && (n2 <= N - 1)
            I2(x,y) = (1-a)*(1-b)*img(n1,n2) + a*(1-b)*img(n1,n2+1) +(1-a)*b*img(n1+1,n2) + a*b*img(n1+1,n2+1);
        end
    end
end
figure(1);imshow(uint8(I2));colormap gray;
end