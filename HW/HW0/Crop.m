function out = Crop(in, start_x, start_y, width, height)
    cropped = in(start_y:(start_y+height),start_x:(start_x+width));
    out = cropped;
end