% (1) spectral on Adj,
% For (1) we should see that the cluster becomes a high-degree vertex neighborhood (this requires n quite large),

import block_model.classifiers.*;
% sbm_class_pics(@sdp_classifier,'sdp',[100 200],2);
% sbm_class_pics(@adj_classifier,'adj', [100000],10);
sbm_class_pics(@lap_classifier,'lap',[100000],2);
% sbm_class_pics(@sym_norm_lap_classifier,'symnormlap',[10000 100000],2);
% sbm_class_pics(@nb_classifier,'nb', [10000 100000],2);