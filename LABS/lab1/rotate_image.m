img = imread('cameraman.tif');
[M,N] = size(img);
newImg = zeros(M,N);
d = 30*pi/180;
R = [cos(d),-sin(d);sin(d),cos(d)];
for x = 1 : M
    for y = 1 : N
    coord = R*[x;y];
    %coord(2) = coord(2) + N;
        if (coord(1) <= M) &&(coord(1)>= 1)&& (coord(2) <= N) && (coord(2) >= 1)
            newImg(floor(coord(1)),floor(coord(2))) = img(x,y);
        end
    end
end
figure(1);imshow(uint8(newImg));colormap gray;
nM = 3*M;
nN = 3*N;
bigger = zeros(nM,nN);
d = 30*pi/180;
R = [cos(d),-sin(d);sin(d),cos(d)];
bigger(M+1:2*M,N+1:2*N) = img;
result = zeros(nM,nN);
for x = 1 : nM
    for y = 1 : nN
    coord = R*[x-M;y-N];
    coord(1) = coord(1) + M;
    coord(2) = coord(2) + N;
        if (coord(1) <= nM) &&(coord(1)>= 1)&& (coord(2) <= nN) && (coord(2) >= 1)
            result(floor(coord(1)),floor(coord(2))) = bigger(x,y);
        end
    end
end
figure(2);imshow(uint8(result));colormap gray;
