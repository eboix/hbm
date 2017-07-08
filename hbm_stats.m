function res = hbm_stats(methodname,n,a,b,c,d,t,trials,out_pref,overwrite)
if nargin == 0
    methodname = 'randwalk';
    n = 20000;
    a = 3.5;
    b = 1;
    c = 15;
    d = 2.5;
    t = 1;
    trials = 10;
    out_pref='res/'
    overwrite=false;
end

filename = sprintf('%s%s_n%d_a%0.2f_b%0.2f_c%0.2f_d%0.2ft_%0.2f.mat', out_pref, methodname, n, a, b, c, d, t);
if exist(filename,'file')
    res = -ones(1,trials);
    return
end
% methodname
% n
% c
% d

res = zeros(trials,1);
giant_ns = zeros(trials,1);
Dlist = zeros(trials,1);

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
        case 'adj'
            [class,V,D] = adj_classifier(obj,giant_A,giant_rev);
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
        Dlist(trialnum) = diag(D);
    else
        Dlist(trialnum) = 0;
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

save(filename, 'res', 'methodname', 'n', 'a', 'b', 'c', 'd', 't', 'giant_ns', 'D');
end