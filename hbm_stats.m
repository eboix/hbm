function res = hbm_stats(methodname,n,a,b,c,d,t,trials)
if nargin == 0
    methodname = 'randwalk';
    n = 20000;
    a = 3.5;
    b = 1;
    c = 15;
    d = 2.5;
    t = 1;
    trials = 10;
end
methodname
n
c
d

res = zeros(trials,1);
giant_ns = zeros(trials,1);
thresh = c/sqrt(n);
Q = [a b; b a]./n;
for trialnum = 1:trials
    % n, prob_dist, t, centers, threshold, Q
    obj = hybrid_block_model(n, [1 1], t, [-d 0; d 0], thresh, Q);
    [giant_A,giant_mask,giant_rev,A,sparseg] = obj.get_giant_adj_matrix();
    giant_n = length(giant_A);
    
    switch methodname
        case 'nbwalk'
            class = nb_classifier(obj);
        case 'adj'
            [class,V,D] = adj_classifier(obj,giant_A,giant_rev);
        case 'norm_adj'
            class = sym_norm_adj_classifier(obj,giant_A,giant_rev);
        case 'lap'
            class = lap_classifier(obj,giant_A,giant_rev);
        case 'randwalk'
            [class,V,D] = randwalk_classifier(obj,giant_A,giant_rev);
        case 'sdp'
            sdp_classifier(obj,giant_A,giant_mask);
        case 'high_deg'
            class = high_deg_classifier(obj,giant_A,giant_mask);
        otherwise
            error('Method "%s" not found.', methodname);
    end
    
    if exist('D','var')
        D = diag(D);
    else
        D = 0;
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
filename = sprintf('res/%s_n%d_a%0.2f_b%0.2f_c%0.2f_d%0.2ft_%0.2f.mat', methodname, n, a, b, c, d, t);

save(filename, 'res', 'methodname', 'n', 'a', 'b', 'c', 'd', 't', 'giant_ns', 'D');
end