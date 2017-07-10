function hbm_stats_parser(N_TO_PARSE, OPT_PARAM)
if nargin == 0
    N_TO_PARSE = 1000;
end
if nargin < 1
    OPT_PARAM = -1;
end

METHOD_TO_PARSE = 'graph_pow_adj';

t_VAL_TO_PARSE = 1;
DO_APPROX_STEP = false;
REFRESH_DATA = false;
SAVE_PLOT = true;
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
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
directory_name = sprintf('res/%s/n%d',METHOD_TO_PARSE,N_TO_PARSE);
combined_file = combine_hbm_stats(directory_name,~REFRESH_DATA);

load(combined_file); % LOAD T.

Trn = T((T.methodname == METHOD_TO_PARSE) & (T.n == N_TO_PARSE) & (T.t == t_VAL_TO_PARSE) & (T.optional_param == OPT_PARAM),:);

% PARSE T.
imgres = cell(length(drange), length(crange));
imggiantn = cell(length(drange), length(crange));
imgtrials = zeros(length(drange), length(crange));
di = 0;
for d = drange
    d
    di = di + 1;
    ci = 0;
    Trnd = Trn(abs(Trn.d - d) <= 0.0001,:);
    for c = crange
        % c
        % d
        ci = ci + 1;
        currtab = Trnd(abs(Trnd.c - c) <= 0.0001,:);
        if size(currtab,1) == 0
            imgres(di,ci) = {NaN};
            imggiantn(di,ci) = {NaN};
            imgtrials(di,ci) = 0;
        else
            imgres(di,ci) = currtab.res(1);
            imgtrials(di,ci) = length(imgres(di,ci));
            imggiantn(di,ci) = currtab.giant_n(1);
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
        for di = 1:length(drange)
            for ci = 1:length(crange)
                if isnan(approxvals(di,ci)) && di > 1
                    approxvals(di,ci) = oldapproxvals(di-1,ci);
                end
                if isnan(approxvals(di,ci)) && di < length(drange)
                    approxvals(di,ci) = oldapproxvals(di+1,ci);
                end
                if isnan(approxvals(di,ci)) && ci < length(crange)
                    approxvals(di,ci) = oldapproxvals(di,ci+1);
                end
                if isnan(approxvals(di,ci)) && ci > 1
                    approxvals(di,ci) = oldapproxvals(di,ci-1);
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
heatmap(approxvals,crange,drange,[],'NanColor', [1 1 1],'ColorBar',true,'MinColorValue',0.5,'MaxColorValue',1)
xlabel('c');
ylabel('d');
title(PLOT_TITLE);
h = gcf;
set(h,'PaperOrientation','landscape');
pause(0.1);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);
pdfname = sprintf('manual_figs/%s.pdf',PDF_NAME);
if SAVE_PLOT
    export_fig(pdfname,'-q101')
end
% print('-fillpage',pdfname,'-dpdf')
end