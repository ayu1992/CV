function g = convolve1D(f,h)
    N = length(f);
    hh = cat(2,zeros(1,N-length(h)),h);
    M = length(hh);
    g = zeros(1,N+M-1);
    for n = 1 : N+M-1
        for i = 1 : N 
           if (n-i > 0) & (n-i <= M)
            g(n) = g(n) + f(i) * hh(n-i);
           end
        end
    end
end