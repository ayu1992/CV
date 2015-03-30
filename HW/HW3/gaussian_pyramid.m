% h = fspecial('gaussian', hsize, sigma);
function pyramid = gaussian_pyramid(img, hsize, levels, sigma)
    hg = fspecial('gaussian', hsize, sigma);    
    for i = 1 : levels        
        imageG = conv2(img, hg, 'same');
        pyramid{i} = imageG;
        img = imageG(1:2:end, 1:2:end);
        %figure;imshow(uint8(img));
    end
end