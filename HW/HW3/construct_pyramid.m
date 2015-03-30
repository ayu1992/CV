function pyramid = construct_pyramid(input_image, levels, hsize, sigma)
    hg = fspecial('gaussian', hsize, sigma);    
    img = input_image;  
    
    for i = 1 : levels        
        imageG = conv2(img, hg, 'same'); 
        imageD = double(img) - imageG;
        pyramid{i} = imageD;
        img = imageG(1:2:end, 1:2:end);
    end
    pyramid{levels+1} = img;  % use an additional level to store a blurred smaller image
end