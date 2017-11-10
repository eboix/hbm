%%%%%% SDP DOESN'T FAIL. THE PROBLEM IS THAT FOR SMALL N THERE IS OFTEN NO
%%%%%% UNIQUE GIANT (FOR a VERY CLOSE TO 2) --> THE BISECTION SDP DOES OF
%%%%%% THE LARGEST COMPONENT IS A VERY BAD GUESS. ALL THE VERTICES SHOULD
%%%%%% BE CLUSTERED TOGETHER INSTEAD.


import block_model.classifiers.*;
import block_model.hybrid_block_model;

n = 300;

% A regime in which the SDP fails.
a = 2.01;
b = -sqrt(4*a + 1) + a + 1;
a = a - 0.01; % Go slightly below KS threshold, so recovery is possible at large n.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTANTIATE SBM MODEL                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
community_rel_sizes = [1 1];
SBM_MODEL = 0;
gbm_junk = -1; % Parameters not needed for pure SBM.
Q = [a b; b a]/n;
sbm = hybrid_block_model(n,community_rel_sizes,SBM_MODEL,gbm_junk,gbm_junk,Q);

[~,giant_mask,~] = sbm.get_giant_adj_matrix();
frac_giant = sum(giant_mask)/n

% Run Classifier
class_guess = sdp_classifier(sbm);
[agree_class,~] = sbm.giant_classification_agreement(class_guess);

% Four possiblities
% 2 for which hidden label you have, and 2 for which class you're in.

% sbm_graph = sbm.get_graph();
% fh = figure;
% plot(sbm_graph);

colors = 'rgbc';

% for i = 1:length(