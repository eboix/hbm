function hbm_stats_parser(parse_config)
run(parse_config);
if ABPLOT
    length_modifier = length(c_vals) * length(d_vals);
else
    length_modifier = length(a_vals) * length(b_vals);
end
pdfnames = cell(1,length(n_vals) * length(optional_param_vals) * length(t_vals) * length_modifier);
i = 1;
for n = n_vals
    for opt = optional_param_vals
        for t = t_vals
            if ABPLOT
                for c = c_vals
                    for d = d_vals
                        pdfnames{i} = hbm_stats_parser_helper(methodname, n, opt, t, ABPLOT, a_vals, b_vals, c, d,USE_KMEANS);
                        i = i + 1;
                    end
                end
            else
                for a = a_vals
                    for b = b_vals
                        pdfnames{i} = hbm_stats_parser_helper(methodname, n, opt, t, ABPLOT, a, b, c_vals, d_vals,USE_KMEANS);
                        i = i + 1;
                    end
                end
            end
        end
    end
end
[~,name,~] = fileparts(parse_config);
append_pdfs(['job_pdfs/' name '.pdf'], pdfnames{:});

end

function pdfname = hbm_stats_parser_helper(METHOD_TO_PARSE, N_TO_PARSE, OPT_TO_PARSE, t_VAL_TO_PARSE, ABPLOT, arange, brange, crange, drange, use_kmeans)

DO_APPROX_STEP = false;
SAVE_PLOT = true;

if OPT_TO_PARSE == -1
    PDF_NAME = sprintf('%s_n%d_t%f',METHOD_TO_PARSE,N_TO_PARSE);
else
    PDF_NAME = sprintf('%s_n%d_param%d',METHOD_TO_PARSE,N_TO_PARSE,OPT_TO_PARSE);
end

if OPT_TO_PARSE == -1
    PLOT_TITLE = sprintf('%s success, 1 trial, n = %d', strrep(METHOD_TO_PARSE,'_',' '), N_TO_PARSE);
else
    PLOT_TITLE = sprintf('%s(%d) success, 1 trial, n = %d', strrep(METHOD_TO_PARSE,'_',' '), OPT_TO_PARSE, N_TO_PARSE);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
directory_name = sprintf('res/%s/n%d',METHOD_TO_PARSE,N_TO_PARSE);
combined_file = combine_hbm_stats(directory_name,true);

load(combined_file); % LOAD T.

Trn = T((T.methodname == METHOD_TO_PARSE) & (T.n == N_TO_PARSE) & (T.t == t_VAL_TO_PARSE) & (T.optional_param == OPT_TO_PARSE) & (T.use_kmeans == use_kmeans),:);

if ABPLOT
    xrange = arange;
    yrange = brange;
    assert(length(crange) == 1);
    assert(length(drange) == 1);
    Trn = Trn(abs(Trn.c - crange) <= 0.00001,:);
    Trn = Trn(abs(Trn.d - drange) <= 0.00001,:);
    PLOT_TITLE = sprintf('%s, t = %0.2f, c = %0.2f, d = %0.2f', PLOT_TITLE, t_VAL_TO_PARSE,crange,drange);
    PDF_NAME = sprintf('%s_t%0.2f_c%0.2f_d%0.2f', PDF_NAME, t_VAL_TO_PARSE, crange, drange);
else
    xrange = crange;
    yrange = drange;
    assert(length(arange) == 1);
    assert(length(brange) == 1);
    Trn = Trn(abs(Trn.a - arange) <= 0.00001,:);
    Trn = Trn(abs(Trn.b - brange) <= 0.00001,:);
    PLOT_TITLE = sprintf('%s, t = %0.2f, a = %0.2f, b = %0.2f', PLOT_TITLE, t_VAL_TO_PARSE,arange,brange);
    PDF_NAME = sprintf('%s_t%0.2f_a%0.2f_b%0.2f', PDF_NAME, t_VAL_TO_PARSE, arange, brange);
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
if strcmp(METHOD_TO_PARSE, 'giant_size')
    mres = cellfun(@(x) sum(x)/length(x), imggiantn);
else
    mres = cellfun(@(x) sum(x)/length(x), imgres);
end
mres(mres == 0) = NaN;

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
if strcmp(METHOD_TO_PARSE, 'giant_size')
    mincolorval = 0;
    maxcolorval = N_TO_PARSE;
else
    mincolorval = 0.5;
    maxcolorval = 1;
end
heatmap(approxvals,xrange,yrange,[],'NanColor', [1 1 1],'ColorBar',true,'MinColorValue',mincolorval,'MaxColorValue',maxcolorval)
if ABPLOT
    xlabel('a');
    ylabel('b');
else
    xlabel('c');
    ylabel('d');
end

if ABPLOT
    % Plot the KS-threshold for pure SBM.
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
    try
        export_fig(pdfname,'-q101')
    catch
        print('-fillpage',pdfname,'-dpdf')
    end
end
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