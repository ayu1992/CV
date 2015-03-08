function edge_image = detect_edges(input_image, hsize, sigma, Thigh, Tlow)
    close all;
    hg = fspecial('gaussian', hsize, sigma);
    [N M] = size(input_image);
    % denoise
    imgD = conv2(input_image, hg);
    imageG = imgD(hsize/2+1:hsize/2+N,hsize/2+1:hsize/2+M);
    figure;imshow(uint8(imageG));
    % calculate gradient intensity : generate edges with Sobel operators
    Sx = [1 2 1];
    Sy = [-1 0 1];
    
    Gx = Sx'*Sy;            
    Gy = Sy'*Sx;
    
    GradientX = conv2(imageG, Gx, 'same');
    GradientY = conv2(imageG, Gy, 'same');
    
    GradientX = GradientX(4:236,4:236);
    GradientY = GradientY(4:236,4:236);
    N = 236 - 4 + 1;
    M = 236 - 4 + 1;
    % strength and direction of each gradient
    G = sqrt(GradientX.^2 + GradientY.^2);     
    theta = atan2(abs(GradientY),abs(GradientX));           % use atan?
    figure;imshow(uint8(G));
    max(max(theta))
    % round directions into 4 angles
    k = pi/4;   % (3pi/4 )/ 3
    roundedTheta = round(theta./k)*k;
    
    dir0 = zeros(N,M);
    dir45 = zeros(N,M);
    dir90 = zeros(N,M);
    dir135 = zeros(N,M);
    
    % indicator matrices
    dir0(roundedTheta == 0) = 1;        % indicated locations that are 0 degrees
    dir45(roundedTheta == k) = 1;
    dir90(roundedTheta == 2*k) = 1;
    dir135(roundedTheta == 3*k) = 1;    % dir0 + dir45 + dir90 + dir135 = ones(N,M)
    
    % non-maximum suppression : sharpen edges
    Gout = zeros(N,M);
    % direction : 90 degrees
    G90 = G.*dir90;
    figure;imshow(uint8(G90));
    G0 = G.*dir0;
    figure;imshow(uint8(G0));
    G45 = G.*dir45;
    figure;imshow(uint8(G45));
    G135 = G.*dir135;
    max(max(G135))
    figure;imshow(uint8(G135));
    %roundedTheta(1:5,1:5)
    %G(1:5,1:5)
    %G0(1:5,1:5)
    for x = 1 : N           % for each column
        for y = 1 : M
            if (x + 1 <= N) && (x-1 >= 1) && (G90(x,y) > G90(x+1, y)) && (G90(x,y) > G90(x-1, y))
                Gout(x,y) = G90(x,y);
            end
        end
    end
    max_in_row = max(G0');     % take row-wise maximum
    for x = 1 : N           % for each column
        for y = 1 : M
            if (y + 1 <= M) && (y-1 >= 1) && (G0(x,y) > G0(x, y+1)) && (G0(x,y) > G0(x, y-1))
                Gout(x,y) = G0(x,y);
            end
        end
    end
   
    % direction : 45 degrees
    % central diagonal
    for x = 1 : N
        if (x + 1 <= N) && (x-1 >= 1) && (G45(x,x) > G45(x+1, x+1)) && (G45(x,x) > G45(x-1, y-1))
            Gout(x,x) = G45(x,x);
        end
    end
    % lower left submatrix
    for x = 2 : N-1         % index of top left corner 
        %m = max(diag(G45(x : N, 1 : M - x + 1)));
        % traverse the diagonal of the matrix
        j = 1;
        for i = x : N
            if (x + 1 <= N) && (x-1 >= 1) && (j+1 <= M) && (j-1 >=1) && (G45(x,j) > G45(x+1, j+1)) && (G45(x,j) > G45(x-1, j-1))
                Gout(x,j) = G45(x,j);
            end
        j = j + 1;    
        end
    end
    % upper right submatrix
    for y = 2 : M-1 
        %m = max(diag(G45(1 : N - y + 1, y : M)));
        % traverse the diagonal of the matrix
        i = 1;
        for j = y : M
            if (y + 1 <= M) && (y-1 >= 1) && (i+1 <= N) && (i-1 >=1) && (G45(i,y) > G45(i+1, y+1)) && (G45(i,y) > G45(i-1, y-1))
                Gout(i,y) = G45(i,y);
            end
            i = i + 1;
        end
    end
     figure;imshow(uint8(Gout));title('non-max');
    % double thresholding
    highest = max(max(G))
    H = Thigh * highest;
    L = H * Tlow;
    for x = 1 : N
        for y = 1 : M
            if Gout(x,y) >= H
                Gout(x,y) = 255;
            elseif L <= Gout(x,y)
                Gout(x,y) = 128;
            else
                Gout(x,y) = 0;
            end
        end
    end
     figure;imshow(uint8(Gout));title('double suppression');
    figure;imshow(edge(input_image,'Canny'));title('Edge');
end