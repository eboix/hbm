function agree_vals = agree_vals_sbm(class_func, a, b, n, num_trials)

import block_model.hybrid_block_model;

    if nargin < 5
        num_trials = 1;
    end

    agree_vals = zeros(1,num_trials);
  
    parfor i = 1:num_trials
        community_rel_sizes = [1 1];
        SBM_MODEL = 0;
        gbm_junk = -1; % Parameters not needed for pure SBM.
        Q = [a b; b a]/n;
        sbm = hybrid_block_model(n,community_rel_sizes,SBM_MODEL,gbm_junk,gbm_junk,Q);

        class_guess = class_func(sbm);
        [agree_class,~] = sbm.giant_classification_agreement(class_guess);
        agree_vals(i) = agree_class;
    end
end