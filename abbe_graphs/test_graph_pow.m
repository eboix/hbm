import block_model.*;
import block_model.classifiers.*;

thresh_c = 10;
center_dist = 2;
n = 20000;
thresh = thresh_c/sqrt(n);

community_rel_sizes = [1 1];
GBM_MODEL = 1;
sbm_junk = -1; % Parameters not needed for pure GBM.
center = [[0 0]; [center_dist 0]];
gbm = hybrid_block_model(n,community_rel_sizes,GBM_MODEL,center,thresh,sbm_junk);

class_guess = adj_classifier(gbm);
class_guess_pow = pow_classifier(@adj_classifier, gbm, 'clean_c',2, 'pow_c',0.15);

[agree_class,~] = gbm.giant_classification_agreement(class_guess);
[agree_class_pow,~] = gbm.giant_classification_agreement(class_guess_pow);
optimal_agree = gbm.giant_classification_agreement(optimal_gbm_classifier(gbm));
agree_class
agree_class_pow
optimal_agree

% [clean_A,clean_mask,clean_rev] = clean_graph(gbm.get_adj_matrix(), C);
% plot(graph(clean_A))