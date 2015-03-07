function edge_image = detect_edges(input_image, hsize, sigma, Thigh, Tlow)
    hg = fspecial('gaussian', hsize, sigma);
    [N M] = size(input_image);
    % denoise
    imgD = conv2(input_image, hg, 'same');
    % calculate gradient intensity : generate edges
    Sx = [1 2 1];
    Sy = [-1 0 1];
    Gx = Sx'*Sy;            
    Gy = Sy'*Sx;
    GradientX = conv2(imgD, Gx, 'same');
    GradientY = conv2(imgD, Gy, 'same');
    G = sqrt(GradientX.^2 + GradientY.^2);      % strength of gradient
    theta = atan2(abs(GradientY),abs(GradientX));           % use atan?
    % round theta into 4 angles
    k = pi/4;   % (3pi/4 )/ 3
    roundedTheta = round(theta./k)*k;
    
    dir0 = zeros(N,M);
    dir45 = zeros(N,M);
    dir90 = zeros(N,M);
    dir135 = zeros(N,M);
    
    dir0(roundedTheta == 0) = 1;        % indicated locations that are 0 degrees
    dir45(roundedTheta == k) = 1;
    dir90(roundedTheta == 2*k) = 1;
    dir135(roundedTheta == 3*k) = 1;    % dir0 + dir45 + dir90 + dir135 = ones(N,M)
    
    % non-maximum suppression : sharpen edges
    Gout = zeros(N,M);
    % direction : 90 degrees
    G90 = G.*dir90;
    %roundedTheta(1:5,1:5)
    %G(1:5,1:5)
    %G0(1:5,1:5)
    max_in_col = max(G90);     % m = max value for each column 
    for x = 1 : N           % for each column
        for y = 1 : M
            if G90(x,y) == max_in_col(y)
                Gout(x,y) = G90(x,y);
            end
        end
    end
    % direction : 0 degrees
    G0 = G.*dir0;
    max_in_row = max(G0');     % take row-wise maximum
    for x = 1 : N           % for each column
        for y = 1 : M
            if G0(x,y) == max_in_row(x)
                Gout(x,y) = G0(x,y);
            end
        end
    end
    figure;imshow(Gout);
    % direction : 
    
end