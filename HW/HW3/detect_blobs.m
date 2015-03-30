function blobs_image = detect_blobs(input_image)
    close all;
    img = rgb2gray(imread(sprintf('%s.jpg',input_image)));
    [N M] = size(img);
    hsize =  91;%251;
    pyramid = [];
    
    % build Laplaican pyramid
    
    scales = 5:55;%15 : 10 : 165  
    levels = size(scales,2);
    figure;hold on;
    for level = 1 : levels
        h = fspecial('log', hsize, scales(level));
        imgL = abs(scales(level)^2 * conv2(img, h, 'same'));
        subplot(6,9, level),        % circle : 4,4; circles & sunflower : 6,9
        imagesc(imgL);title(sprintf('level %d', level));
        pyramid = cat(3, pyramid, imgL);
    end
    saveas(gcf,sprintf('q3/%s/pyramid.jpg',input_image));
    
    % compress pyramid
    
    imgM = zeros(N,M);
    sigmas = zeros(N,M);
    for x = 1 : N
        for y = 1 : M
             [value, level]= max(pyramid(x,y,:));
             imgM(x,y) = value;
             sigmas(x,y) = scales(level);
        end
    end
    figure;imagesc(imgM);title('compressed');
    saveas(gcf,sprintf('q3/%s/2_compressed.jpg',input_image));
    
    % non-maximum suppression in 15x15 window : detect circle centers
    imgS = zeros(N,M);
    
    fun = @(x) (x(8,8)==max(max(x)))*max(max(x));
    imgS = nlfilter(imgM,[15 15],fun);
    
    figure;imagesc(imgS);title('non-maximum suppression');colormap gray;
    saveas(gcf,sprintf('q3/%s/3_nonmax.jpg',input_image));
    
    % threshold blobs
    strongest = max(max(imgS));
    threshold = 0.65 * strongest;
    imgS(imgS < threshold) = 0;
    figure;imagesc(imgS);title('thresholded');colormap gray;
    saveas(gcf,sprintf('q3/%s/4_thresholded.jpg',input_image));
    blobs_image = imgS;
    
    % compute radius and plot circle
    
    % position of centers
    [x,y] = find(imgS > 0);
    
    radius = zeros(size(x));

    for i = 1 : size(x,1)
        radius(i) = sqrt(2) * sigmas(x(i),y(i));
    end

    figure;imagesc(img);colormap gray;
    hold on;
    
    % to plot using circles, uncomment line 67 and comment 69 - 73
    %scatter(y,x,pi*radius.^2);
    scatter(y, x,'b','+');
    scatter(round(y-radius),x,'r','+');
    scatter(round(y+radius),x,'r','+');
    scatter(y,round(x-radius),'r','+');
    scatter(y,round(x+radius),'r','+');
    
    saveas(gcf,sprintf('q3/%s/final.jpg',input_image));
    blobs_image = imread(sprintf('q3/%s/final.jpg',input_image));
end