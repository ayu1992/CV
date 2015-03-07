
function image = reconstruct_image(pyramid)
    levels = size(pyramid,2);
    image = pyramid{levels};            % image = v4
    %figure;imshow(uint8(image));
    [N M] = size(image);                
    hg = fspecial('gaussian', 4, 4);
    for i = levels-1 : -1 : 1           % l4 -> l1
        % upsample
        N = 2*N;
        M = 2*M;
        imgRe = zeros(N, M);
        imgRe(1:2:end, 1:2:end) = image;
        figure;imshow(imgRe);
        % blur
        imageG = 4*conv2(imgRe, hg, 'same');
        figure;imshow(imageG);
        % add DoG
        image = imageG + pyramid{i};
        figure;imshow(uint8(image));
    end
end