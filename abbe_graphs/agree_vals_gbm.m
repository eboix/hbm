function agree_vals = agree_vals_gbm(class_func, c, d, n, num_trials, varargin)

import block_model.hybrid_block_model;

    if nargin < 5
        num_trials = 1;
    end

    agree_vals = zeros(1,num_trials);
  
    parfor i = 1:num_trials
        
        thresh = c/sqrt(n);

        community_rel_sizes = [1 1];
        GBM_MODEL = 1;
        sbm_junk = -1; % Parameters not needed for pure GBM.
        center = [[0 0]; [d 0]];
        gbm = hybrid_block_model(n,community_rel_sizes,GBM_MODEL,center,thresh,sbm_junk);

        class_guess = class_func(gbm,varargin{:});
        [agree_class,~] = gbm.giant_classification_agreement(class_guess);
        agree_vals(i) = agree_class;
    end
end