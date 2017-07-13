function [res,giant_ns] = hbm_stats(methodname,n,a,b,c,d,t,trials,out_pref,overwrite,optional_param)
% if nargin == 0
%     methodname = 'randwalk';
%     n = 20000;
%     a = 3.5;
%     b = 1;
%     c = 15;
%     d = 2.5;
%     t = 1;
%     trials = 10;
%     out_pref=sprintf('res/%s/n%d',methodname,n);
%     overwrite=false;
% end

if ~exist(out_pref,'dir')
    if ~mkdir(out_pref)
        error('Unable to create folder %s',out_pref);
    end
end

filename = fullfile(out_pref,sprintf('%s_n%d_a%0.4f_b%0.4f_c%0.4f_d%0.4ft_%0.4f', methodname, n, a, b, c, d, t));
if ~exist('optional_param','var') || optional_param == -1
    optional_param = -1;
else
    filename = sprintf('%s_opt%d',filename,optional_param);
end
filename = sprintf('%s.mat',filename);

if ~overwrite && exist(filename,'file')
    res = -ones(1,trials);
    return
end
% methodname
% n
% c
% d

res = zeros(trials,1);
giant_ns = zeros(trials,1);
Dlist = cell(trials,1);

thresh = c/sqrt(n);
Q = [a b; b a]./n;
for trialnum = 1:trials
    % n, prob_dist, t, centers, threshold, Q
    obj = hybrid_block_model(n, [1 1], t, [-d 0; d 0], thresh, Q);
    
    
    if strcmp(methodname, 'giant_size')
        res(trialnum) = 0;
        cs = obj.get_comp_sizes();
        giant_ns(trialnum) = cs(1);
        D = 0;
        continue
    end
    
    [giant_A,giant_mask,giant_rev,A,sparseg] = obj.get_giant_adj_matrix();
    giant_n = length(giant_A);
    
    switch methodname
        case 'nbwalk'
            class = nb_classifier(obj,giant_mask);
        case 'norm_nbwalk'
            class = norm_nb_classifier(obj,giant_mask);
        case 'adj'
            [class,V,D] = adj_classifier(obj,giant_A,giant_rev);
        case 'graph_pow_adj'
           [class,V,D] = graph_pow_adj_classifier(obj,optional_param,giant_A,giant_rev);
        case 'graph_pow_lap'
            [class,V,D] = graph_pow_lap_classifier(obj,optional_param,giant_A,giant_rev);
        case 'norm_adj'
            class = sym_norm_adj_classifier(obj,giant_A,giant_rev);
        case 'lap'
            class = lap_classifier(obj,giant_A,giant_rev);
        case 'randwalk'
            [class,V,D] = randwalk_classifier(obj,giant_A,giant_rev);
        case 'sdp'
            class = sdp_classifier(obj,giant_A,giant_mask);
        case 'high_deg'
            class = high_deg_classifier(obj,giant_A,giant_mask);
        otherwise
            error('Method "%s" not found.', methodname);
    end
    
    if exist('D','var') % EIGVAL INFO IF THERE IS ANY.
        Dlist{trialnum} = diag(D);
    else
        Dlist{trialnum} = 0;
    end
    
    [agreement, ~] = obj.classification_agreement(class);
    agreement = agreement*n/giant_n;
    %     if obj.t ~= 0
    %         [geo_map_agreement, ~] = obj.classification_agreement_geo_predictor(class);
    %         geo_map_agreement = geo_map_agreement*n/giant_n;
    %     end
    res(trialnum) = agreement;
    giant_ns(trialnum) = giant_n;
end

D = Dlist;

save(filename, 'res', 'methodname', 'n', 'a', 'b', 'c', 'd', 't', 'giant_ns', 'D','optional_param');
end
