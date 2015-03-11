function blobs_image = detect_blobs(input_image)
    close all;
    img = rgb2gray(imread(input_image));
    [N M] = size(img);
    hsize =  251;
    
    pyramid = [];
    
    % build Laplaican pyramid
    
    scales = [5 , 10 , 165];
    for level = 1 : size(scales,2)
        h = fspecial('log', hsize, scales(level));
        imgL = abs(scales(level)^2 * conv2(img, h, 'same'));
        pyramid = cat(3, pyramid, imgL);
    end
    
    % compress pyramid
    imgM = zeros(N,M,2);
    for x = 1 : N
        for y = 1 : M
             [value, level]= max(pyramid(x,y,:));
             imgM(x,y,1) = value;
             imgM(x,y,2) = level;
        end
    end
    figure;imagesc(imgM(:,:,1));title('compressed');
    
    % non-maximum suppression in 15x15 window : detect circle centers
    imgS = zeros(N,M);
    
    fun = @(x) (x(8,8)==max(max(x)))*max(max(x));
    imgS = nlfilter(imgM(:,:,1),[15 15],fun);
    
    figure;imagesc(imgS);title('non-maximum suppression');colormap gray;
    
    % threshold blobs
    strongest = max(max(imgS));
    threshold = 0.65 * strongest;
    imgS(imgS < threshold) = 0;
    figure;imagesc(imgS);title('thresholded');colormap gray;
end