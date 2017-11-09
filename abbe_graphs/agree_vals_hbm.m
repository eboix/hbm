function agree_vals = agree_vals_hbm(class_func, a, b, c, d, t, n, num_trials, varargin)

import block_model.hybrid_block_model;

    if nargin < 5
        num_trials = 1;
    end

    agree_vals = zeros(1,num_trials);
  
    parfor i = 1:num_trials
        community_rel_sizes = [1 1];
        center = [[0 0]; [d 0]];
        thresh = c / sqrt(n);
        Q = [a b; b a]/n;
        
        hbm = hybrid_block_model(n,community_rel_sizes,t,center,thresh,Q);

        class_guess = class_func(hbm,varargin{:});
        [agree_class,~] = hbm.giant_classification_agreement(class_guess);
        agree_vals(i) = agree_class;
    end
end