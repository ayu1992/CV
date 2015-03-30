function edge_image = detect_edges(input_image, hsize, sigma, Thigh, Tlow)

    hg = fspecial('gaussian', hsize, sigma);
    [N M] = size(input_image);
    
    % denoise
    imgD = conv2(input_image, hg);
    imageG = imgD(hsize/2+1:hsize/2+N,hsize/2+1:hsize/2+M);
    figure;imshow(uint8(imageG));title('step 1 denoise');
    saveas(gcf,'q2/1_denoise.jpg');
    
    % calculate gradient intensity : generate edges with Sobel operators
    
    Sx = [1 2 1];
    Sy = [-1 0 1];
    
    Gx = Sx'*Sy;            
    Gy = Sy'*Sx;
    
    GradientX = conv2(imageG, Gx, 'same');
    GradientY = conv2(imageG, Gy, 'same');
    
    % strength and direction of each gradient
    G = sqrt(GradientX.^2 + GradientY.^2);     
    theta = atan2(GradientY,GradientX);           
    figure;imshow(uint8(G));title('step 2 gradient');
    saveas(gcf,'q2/2_gradient.jpg');
    
    % round directions into 4 angles
    k = pi/4;   
    roundedTheta = mod( round(theta./k), 4);
    Gmax = G;
    
    % non-maximum suppression
    for x = 2 : N-1
        for y = 2 : M-1
            switch(roundedTheta(x,y))
                case 0  % 0 degrees direction
                    if (G(x,y) < G(x, y+1)) || (G(x,y) < G(x, y-1))
                     Gmax(x,y) = 0;
                    end
                case 1  % 45 degrees direction
                    if (G(x,y) < G(x-1, y-1)) || (G(x,y) < G(x+1, y+1))
                     Gmax(x,y) = 0;
                    end
                case 2  % 90 degrees direction
                    if (G(x,y) < G(x+1,y)) || (G(x,y) < G(x-1, y))
                     Gmax(x,y) = 0;
                    end
                case 3  % 135 degrees direction
                    if (G(x,y) < G(x-1, y+1)) || (G(x,y) < G(x+1, y-1))
                     Gmax(x,y) = 0;
                    end
            end
        end
    end
    figure;imshow(uint8(Gmax));title('step 3 non-max');
    saveas(gcf,'q2/3_nonmax.jpg');
    
    % hysteresis
    
    highest = max(max(Gmax(5:N-3, 5:M-3)));     % gradient is illdefined on borders, shouldn't be included in calculation
    H = Thigh * highest;
    L = H * Tlow;
    
    Gout = Gmax;
    
    % identify pixels with strength > L
    strong = [];                  
    for x = 1 : N
        for y = 1 : M
            if Gout(x,y) >= H
                strong = [strong, [x;y]];
            end
        end
    end
    
    % display distribution of all strong points
    str = find(Gmax >= H);
    Gdist = zeros(N,M);
    Gdist(str) = 255;
    figure;imshow(Gdist);title('step 4 Strong Distribution');
    saveas(gcf,'q2/4_dist.jpg');
    
    % BFS on strong pixels - finds all connected weak edges

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
    
    figure;imshow(uint8(edge_image));title('step 4 Hysteresis');
    saveas(gcf, 'q2/5_hys.jpg');