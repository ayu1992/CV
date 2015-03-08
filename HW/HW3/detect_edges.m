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
    
    % strength and direction of each gradient
    G = sqrt(GradientX.^2 + GradientY.^2);     
    theta = atan2(GradientY,GradientX);           % use atan?
    figure;imshow(uint8(G));

    % round directions into 4 angles
    k = pi/4;   
    roundedTheta = mod( round(theta./k), 4);
   
    dir0 = zeros(N,M);
    dir45 = zeros(N,M);
    dir90 = zeros(N,M);
    dir135 = zeros(N,M);
    
    % indicator matrices
    dir0(roundedTheta == 0) = 1;        % indicated locations that are 0 degrees
    dir45(roundedTheta == 1) = 1;
    dir90(roundedTheta == 2) = 1;
    dir135(roundedTheta == 3) = 1;    % dir0 + dir45 + dir90 + dir135 = ones(N,M)
    
    % non-maximum suppression : sharpen edges
    Gout = zeros(N,M);
    
   
    G0 = G.*dir0;
    G45 = G.*dir45;
    G90 = G.*dir90;
    G135 = G.*dir135;
    
    % direction: 0 degrees
    for x = 1 : N           % for each column
        for y = 1 : M
            if (y + 1 <= M) && (y-1 >= 1) && (G0(x,y) > G0(x, y+1)) && (G0(x,y) > G0(x, y-1))
                Gout(x,y) = G0(x,y);
            end
        end
    end
   
     % direction : G45 degrees
    for x = 1 : N           % for each column
        for y = 1 : M
            if (y + 1 <= M) && (y-1 >= 1) && (x + 1 <= N) && (x-1 >= 1) && (G45(x,y) > G45(x-1, y-1)) && (G45(x,y) > G45(x+1, y+1))
                Gout(x,y) = G45(x,y);
            end
        end
    end
    
    % direction: 90 degrees
    for x = 1 : N           % for each column
        for y = 1 : M
            if (x + 1 <= N) && (x-1 >= 1) && (G90(x,y) > G90(x+1, y)) && (G90(x,y) > G90(x-1, y))
                Gout(x,y) = G90(x,y);
            end
        end
    end
    
    % direction : G135 degrees
    for x = 1 : N           % for each column
        for y = 1 : M
            if (y + 1 <= M) && (y-1 >= 1) && (x + 1 <= N) && (x-1 >= 1) &&(G135(x,y) > G135(x+1, y-1)) && (G135(x,y) > G135(x-1, y+1))
                Gout(x,y) = G135(x,y);
            end
        end
    end
    figure;imshow(uint8(Gout));title('non-max');
     
    % hysteresis
    highest = max(max(Gout));
    H = Thigh * highest;
    L = H * Tlow;
    
    % identify strong or weak pixels
    strong = [];                        % 2 x k
    for x = 1 : N
        for y = 1 : M
            if Gout(x,y) >= H
                strong = [strong, [x;y]];
            end
        end
    end
    
    % BFS on strong pixels - finds all connected edges
    
    frontier = [];
    q_hd = 1;
    q_tl = 1;
    visited = zeros(N,M);
    n_start = size(strong,2);                   % all possible roots ( all strong pixels)
    
    edge_image = zeros(N,M);
    
    for i = 1 : n_start
        
        frontier = [frontier, strong(:,i)];     % push root to Q
        q_tl = q_tl + 1;                        
        visited(strong(:,i)) = 1;               % mark discovered
        edge_image(strong(:,i)) = 255;                  
        
        while q_hd < q_tl
            
            % pop from Q
            current = frontier(:,q_hd);         
            q_hd = q_hd + 1;
               
            % for all of current's 8 neighbors
            for i = -1 : 1
                for j = -1 : 1
                    x = current(1)+i;
                    y = current(2)+j;
                                    
                    if x <= N && y<= M && x > 0 && y > 0 && (Gout(x , y) >= L) && (visited(x, y) == 0)
                        edge_image(x,y) = 255; 
                        frontier = [frontier, [x;y]];   % push to frontier
                        q_tl = q_tl + 1; 
                        visited(x,y) = 1;               % label as discovered
                    end
                end
            end
        end
    end
    
    figure;imshow(uint8(edge_image));title('Hysteresis');
    
    figure;imshow(edge(input_image,'Canny'));title('Edge');
end