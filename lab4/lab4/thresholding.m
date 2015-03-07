function [corners_thres] = thresholding(corners_values, thres_corner)

%%%% normalize the cornerness values
scalar = 255 / (max(max(corners_values)));
corners_normal = corners_values .* scalar;
figure; imshow(corners_normal); title('Cornerness Normalized');savefig('3-CornersNormalized.fig');

%%%% thresholding
corners_thres = corners_normal;
corners_thres(corners_thres < thres_corner) = 0;
figure; imshow(corners_thres); title('Cornerness -- Threshold');savefig('3-CornersThresholded.fig');