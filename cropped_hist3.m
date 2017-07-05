function [ dmap, C ] = cropped_hist3(xy, dims, limits)
%DATADENSITY Get a 2D histogram for the data, cropping out points farther
%than x and y.
%   xy - [x y], n x 2 array.
%   wh = [width height], length(wh) = 2, number of boxes for histogram.
%   limits - [xmin xmax ymin ymax] - defaults to data max/min
    if(nargin == 0)
        error('Enter argument xy.')
    end
    if(nargin == 1)
        dims = [25 25];
    end
    if(nargin <= 2)
        limits(1) = min(xy(:,1));
        limits(2) = max(xy(:,1));
        limits(3) = min(xy(:,2));
        limits(4) = max(xy(:,2));
    end
    boxwidth = (limits(2) - limits(1)) / dims(1);
    boxheight = (limits(4) - limits(3)) / dims(2);
    xcenters = linspace(limits(1) + boxwidth / 2, limits(2) - boxwidth / 2, dims(1));
    ycenters = linspace(limits(3) + boxheight / 2, limits(4) - boxheight / 2, dims(2));
    ctrs = {xcenters ycenters};
    [dmap, C] = hist3(xy, ctrs);
end