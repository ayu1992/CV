function [im_out] = suppressNonMaxima(im_in,nsize)

[m,n] = size(im_in);
im_out = zeros(m,n);

for i = nsize+1:m-nsize
    for j = nsize+1:n-nsize
        % get window of size (2*nsize+1) centered at (i,j)
        % get max value within the window
        max_val = max(max(im_in(i-nsize:i+nsize, j-nsize:j+nsize)));
        % copy the value at (i,j) to output if it is equal to the max
        if im_in(i,j) == max_val
            im_out(i,j) = max_val;
        end
    end
end
%im_out = im_in;
figure; imshow(im_out); title('Cornerness -- Maxima');savefig('4-CornersSuppressed.fig');