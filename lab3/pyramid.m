% h = fspecial('gaussian', hsize, sigma);
function result = pyramid(image, levels, sigma)
    hg = fspecial('gaussian', 10, sigma);    
    img = imread(image);
    figure(1);imshow(uint8(img));
    f = figure(2);
    for i = 1 : levels        
        [N M] = size(img);
        imageG = conv2(img, hg, 'same');
        img = imageG(1:2:end, 1:2:end);
        subplot(1,levels,i);imshow(uint8(img));
    end
    result = img;
    saveas(f, 'pyramid.jpg');
end