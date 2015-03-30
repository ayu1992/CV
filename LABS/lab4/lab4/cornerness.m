function [corners_values] = cornerness(Ix,Iy,sigma_corner,winsz_corner,k_corner)

%%%% compute Ixxw, Ixyw, and Iyyw
% compute Ixx
% compute Ixy
% compute Iyy
% generate Gaussian kernel
% convolve to get Ixxw
% convolve to get Ixyw
% convolve to get Iyyw

%%%% compute the cornerness values

Ixx_w = Ix.^2;
Iyy_w = Iy.^2;
Ixy_w = Ix.*Iy;
w = fspecial('Gaussian', [5 5], 1);
Ixx_w = conv2(Ixx_w, w, 'same');
Iyy_w = conv2(Iyy_w, w, 'same');
Ixy_w = conv2(Ixy_w, w, 'same');
det_A = Ixx_w.*Iyy_w - Ixy_w.*Ixy_w;
trace_A = Ixx_w + Iyy_w;
corners_values = det_A - 0.1*(trace_A).^2;
%%%% plot the cornerness values
figure; imshow(corners_values); title('Cornerness'); savefig('2-Corners.fig');