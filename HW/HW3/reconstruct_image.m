
function image = reconstruct_image(pyramid)
    levels = size(pyramid,2);
    image = pyramid{levels};           
    [N M] = size(image);         
    figure;imshow(uint8(image));title('Top Level');
    saveas(gcf,'q1/1_r1.jpg');
    for i = levels-1 : -1 : 1           % l4 -> l1
        % upsample
        N = 2*N;
        M = 2*M;
        imgRe = zeros(N, M);
        imgRe(1:2:end, 1:2:end) = image;
        figure;imshow(uint8(imgRe));title('upsample');
        saveas(gcf,sprintf('q1/1_r_level%d_up.jpg',levels - i));
        % interpolate
        inds = -N/2:N/2;
        A = sin(pi/2*inds) ./ (pi/2*inds);
        A(N/2+1) = 1;
        hg = A'*A;
        imageG = conv2(imgRe, hg, 'same');
        figure;imshow(uint8(imageG));title('interpolate');
        saveas(gcf,sprintf('q1/1_r_level%d_intr.jpg',levels - i));
        % add DoG
        image = imageG + pyramid{i};
        figure;imshow(uint8(image));title('add DoG');
        saveas(gcf,sprintf('q1/1_r_level%d_DoG.jpg',levels - i));
    end
end