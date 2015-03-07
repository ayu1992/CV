function result = DoG(image, levels, sigma)
    hg = fspecial('gaussian', 10, sigma);    
    img = imread(image);
    figure(1);imshow(uint8(img));
    f = figure(2);
    for i = 1 : levels        
        [N M] = size(img);
        imageG = conv2(img, hg, 'same');
        imageD = double(img) - imageG;
        img = imageG(1:2:end, 1:2:end);
        subplot(1,levels,i);imshow(imageD,[]);
    end
    result = img;
    saveas(f, 'DoG.jpg');
end