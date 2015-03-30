function blended_image = blend_image(image1, image2)
    clear all;
    close all;
    levels = 5;
    hsize = 5;
    sigma = 1.4;
    [N M C] = size(image1);
    
    % build a Laplacian pyramid for both images
    
    p1r = construct_pyramid(image1(:,:,1), levels, hsize, sigma);
    p1g = construct_pyramid(image1(:,:,2), levels, hsize, sigma);
    p1b = construct_pyramid(image1(:,:,3), levels, hsize, sigma);
    p2r = construct_pyramid(image2(:,:,1), levels, hsize, sigma);
    p2g = construct_pyramid(image2(:,:,2), levels, hsize, sigma);
    p2b = construct_pyramid(image2(:,:,3), levels, hsize, sigma);

    % build a Gaussian mask for selected region
    
    mask = cat(2, ones(N, M/2), zeros(N, M/2));
    G = gaussian_pyramid(mask, hsize, levels+1, sigma);
     % display masks
    levelG = size(G,2);
    figure;
    for i = 1 : levelG
        [n m] = size(G{i});
        subplot(1, levelG, i),
        imshow(G{i});title(sprintf('%d x %d', n, m));
    end
    saveas(gcf,'q4/G.jpg');
    % build a blended Laplacian pyramid
    
    for i = 1 : levels+1
        blendedr{i} = G{i} .* p1r{i} + (1 - G{i}) .* p2r{i}; 
        blendedg{i} = G{i} .* p1g{i} + (1 - G{i}) .* p2g{i}; 
        blendedb{i} = G{i} .* p1b{i} + (1 - G{i}) .* p2b{i}; 
    end
    
    % display blended pyramid
    levelB = size(blendedr,2);
    
    for i = 1 : levelB
        [n m] = size(blendedr{i});
        figure;
        imagesc(blendedr{i});colormap gray;title(sprintf('%d x %d', n, m));
        saveas(gcf,sprintf('q4/blendedr%d.jpg',i));
    end
    
    % reconstruct image
    imgr = reconstruct_image(blendedr);
    imgg = reconstruct_image(blendedg);
    imgb = reconstruct_image(blendedb);
    figure; imshow(uint8(imgr));saveas(gcf,'q4/imgr.jpg');
    
    blended_image = cat(3, imgr, imgg, imgb);
end