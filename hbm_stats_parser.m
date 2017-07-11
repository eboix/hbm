function hbm_stats_parser(N_TO_PARSE, OPT_PARAM)
if nargin < 1
    N_TO_PARSE = 1000;
end
if nargin < 2
    OPT_PARAM = -1;
end

METHOD_TO_PARSE = 'adj';

DO_APPROX_STEP = false;
REFRESH_DATA = false;
SAVE_PLOT = true;

% OTHERWISE THIS IS A CD PLOT.
ABPLOT = true;
t_VAL_TO_PARSE = 0;

arange = 2:0.05:2.5;
brange = 0:0.05:0.5;
drange = 0:0.1:4;
crange = 0:0.1:20;

if OPT_PARAM == -1
    PDF_NAME = sprintf('%s_n%d',METHOD_TO_PARSE,N_TO_PARSE);
else
    PDF_NAME = sprintf('%s_n%d_param%d',METHOD_TO_PARSE,N_TO_PARSE,OPT_PARAM);
end

if OPT_PARAM == -1
    PLOT_TITLE = sprintf('%s success, 1 trial, n = %d', strrep(METHOD_TO_PARSE,'_',' '), N_TO_PARSE);
else
    PLOT_TITLE = sprintf('%s(%d) success, 1 trial, n = %d', strrep(METHOD_TO_PARSE,'_',' '), OPT_PARAM, N_TO_PARSE);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
directory_name = sprintf('res/%s/n%d',METHOD_TO_PARSE,N_TO_PARSE);
combined_file = combine_hbm_stats(directory_name,~REFRESH_DATA);

load(combined_file); % LOAD T.

Trn = T((T.methodname == METHOD_TO_PARSE) & (T.n == N_TO_PARSE) & (T.t == t_VAL_TO_PARSE) & (T.optional_param == OPT_PARAM),:);

if ABPLOT
    xrange = arange;
    yrange = brange;
else
    xrange = crange;
    yrange = drange;
end

% PARSE T.
imgres = cell(length(yrange), length(xrange));
imggiantn = cell(length(yrange), length(xrange));
imgtrials = zeros(length(yrange), length(xrange));
yi = 0;
for y = yrange
    y
    yi = yi + 1;
    xi = 0;
    if ABPLOT
        Trny = Trn(abs(Trn.b - y) <= 0.00001,:);
    else
        Trny = Trn(abs(Trn.d - y) <= 0.00001,:);
    end
    for x = xrange
        % c
        % d
        xi = xi + 1;
        if ABPLOT
            currtab = Trny(abs(Trny.a - x) <= 0.00001,:);
        else
            currtab = Trny(abs(Trny.c - x) <= 0.00001,:);
        end
        if size(currtab,1) == 0
            imgres(yi,xi) = {NaN};
            imggiantn(yi,xi) = {NaN};
            imgtrials(yi,xi) = 0;
        else
            imgres(yi,xi) = currtab.res(1);
            imgtrials(yi,xi) = length(imgres(yi,xi));
            imggiantn(yi,xi) = currtab.giant_n(1);
        end
    end
end

mintrials = min(imgtrials);
maxtrials = max(imgtrials);
mres = cellfun(@(x) sum(x)/length(x), imgres);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIONALLY FILL WITH APPROX DATA:
approxvals = mres;
if DO_APPROX_STEP && sum(sum(~isnan(approxvals))) ~= 0
    approx_iter = 0;
    while(sum(sum(isnan(approxvals))) ~= 0)
        approx_iter = approx_iter + 1
        oldapproxvals = approxvals;
        for yi = 1:length(yrange)
            for xi = 1:length(xrange)
                if isnan(approxvals(yi,xi)) && yi > 1
                    approxvals(yi,xi) = oldapproxvals(yi-1,xi);
                end
                if isnan(approxvals(yi,xi)) && yi < length(yrange)
                    approxvals(yi,xi) = oldapproxvals(yi+1,xi);
                end
                if isnan(approxvals(yi,xi)) && xi < length(xrange)
                    approxvals(yi,xi) = oldapproxvals(yi,xi+1);
                end
                if isnan(approxvals(yi,xi)) && xi > 1
                    approxvals(yi,xi) = oldapproxvals(yi,xi-1);
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO THE PLOT
color_res = 1024;
colormap(jet(color_res));
disp('About to draw heatmap.')
heatmap(approxvals,xrange,yrange,[],'NanColor', [1 1 1],'ColorBar',true,'MinColorValue',0.5,'MaxColorValue',1)
if ABPLOT
    xlabel('a');
    ylabel('b');
else
    xlabel('c');
    ylabel('d');
end

if ABPLOT
    x = linspace(xrange(1),xrange(end),1000);
    y = -sqrt(4*x + 1) + x + 1;
    plot_fun_with_axes(x,y,xrange,yrange);
end

title(PLOT_TITLE);
h = gcf;
set(h,'PaperOrientation','landscape');
pause(0.1);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);
h = gca;
h.YDir = 'normal';
pdfname = sprintf('manual_figs/%s.pdf',PDF_NAME);
if SAVE_PLOT
    export_fig(pdfname,'-q101')
end
% print('-fillpage',pdfname,'-dpdf')
end

function plot_fun_with_axes(x,y,xrange,yrange)
    h = gca;
    xlim = h.XLim;
    ylim = h.YLim;
    xside = (xrange(end) - xrange(1)) / length(xrange);
    yside = (yrange(end) - yrange(1)) / length(yrange);
    x = (x - xrange(1))/xside + 0.5;
    y = (y - yrange(1))/yside + 0.5;
    hold on;
    plot(x,y,'k');
    h.XLim = xlim;
    h.YLim = ylim;
    hold off;
end