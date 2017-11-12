% (1) spectral on Adj,
% For (1) we should see that the cluster becomes a high-degree vertex neighborhood (this requires n quite large),

import block_model.classifiers.*;
% gbm_class_pics(@sdp_classifier,'sdp',[100 200],2);
gbm_class_pics(@adj_classifier,'adj', [20000],1);
% gbm_class_pics(@lap_classifier,'lap',[50000],1);
% gbm_class_pics(@sym_norm_lap_classifier,'normlap',[50000],1);
% gbm_class_pics(@nb_classifier,'nb', [50000],1);
% gbm_class_pics(@pow_adj_classifier, 'graphpow (adj)', 2000,1);
% gbm_class_pics(@optimal_gbm_classifier, 'optimal gbm', 50000,1);