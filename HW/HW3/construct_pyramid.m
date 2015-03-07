%pyramid has levels
function pyramid = construct_pyramid(input_image, levels, hsize, sigma)
    hg = fspecial('gaussian', hsize, sigma);    
    img = imread(input_image);  
    for i = 1 : levels        
        [N M] = size(img);
        imageG = conv2(img, hg, 'same');
        imageD = double(img) - imageG;
        pyramid{i} = imageD;
        img = imageG(1:2:end, 1:2:end);
        figure;imshow(pyramid{i});
    end
    pyramid{levels+1} = img;        % level = 4 -> 5 stores small img
    figure;imshow(uint8(pyramid{levels+1}));
end