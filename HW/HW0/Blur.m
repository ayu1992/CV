function out = Blur(img, w)
    [N,M] = size(img);
    h = ones(w,w);
    out = zeros(N,M);
    % No zero padding
    for n = 1:1:N
        for m = 1:1:M
            sum = 0;
            denom = 0;
            for p = 1:1:w
                for q = 1:1:w
                    pp = p - round(w/2);
                    qq = q - round(w/2);
                    if(n-qq>0) & (m-pp >0) &(n-qq<=N) &(m-pp <= M)
                    sum = sum + h(q,p) * img(n - qq,m - pp);
                    denom = denom + 1;
                    end
                end
            end
            out(n,m) = sum/denom;
        end
    end
end