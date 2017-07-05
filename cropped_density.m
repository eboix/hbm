function [ dmap, C, minmaxscaling ] = cropped_density(xy, dims, limits, minmaxscaling)
%cropped_hist3 Get a 2D histogram for the data, cropping out points farther
%than x and y.
%   xy - [x y], n x 2 array.
%   wh = [width height], length(wh) = 2, number of boxes for histogram.
%   minmax = [a b], scale histogram colors linearly, a is min and b is max.
%   limits - [xmin xmax ymin ymax] - defaults to data max/min
    if(nargin == 0)
        error('Enter argument xy.')
    end
    if(nargin == 1)
        dims = [25 25];
    end
    if(nargin <= 2)
        [dmap,C] = cropped_hist3(xy, dims);
    else
        [dmap,C] = cropped_hist3(xy, dims, limits);
    end
    
    if(nargin <= 3)
        minmaxscaling = [min(min(dmap)) max(max(dmap))];
    end
    color_res = 1024;
    colormap(jet(color_res));
    dmapp = color_res*(dmap-minmaxscaling(1))/(minmaxscaling(2) - minmaxscaling(1));
    % pcolor(dmap)
    image([limits(1) limits(2)], [limits(3) limits(4)], dmapp');
   % ax = gca;
   % ax.XTick = linspace(limits(1),limits(2), 10);
end
