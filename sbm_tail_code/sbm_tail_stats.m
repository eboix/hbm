import block_model.utility.*;
import block_model.hybrid_block_model;
import block_model.classifiers.*;

val = zeros(10,3);

for i = 1:10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTANTIATE SBM MODEL                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KS-threshold is (a-b)^2 / (2(a+b)) > 1.
% So given a > 2, we can calculate the threshold value for b.
a = 2.2;
b = -sqrt(4*a + 1) + a + 1;
a = a - 0.01; % Go slightly below KS threshold.

n = 100000;
community_rel_sizes = [1 1];
SBM_MODEL = 0;
gbm_junk = -1; % Parameters not needed for pure SBM.
Q = [a b; b a]/n;

sbm = hybrid_block_model(n,community_rel_sizes,SBM_MODEL,gbm_junk,gbm_junk,Q);

[giant_A,giant_mask,giant_rev] = sbm.get_giant_adj_matrix();
giant_size = sum(giant_mask);
giant_graph = graph(giant_A);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND DANGLING ENDS OF GIANT          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dangling ends are deg-1 and deg-2 vertex paths.
% Filter to only degree-1 and degree-2 vertices.
giant_degs = sum(giant_A);
deg1 = find(giant_degs == 1);
deg2 = find(giant_degs == 2);
filtered_nodes = [deg1 deg2];
filtered_graph = subgraph(giant_graph, filtered_nodes);
% Connected components of filtered graph containing
% degree-1 vertices of the original graph.
tconns = conncomp(filtered_graph);
dangling_ends = filtered_nodes(tconns <= length(deg1));
dangling_mask = zeros(n,1);
dangling_mask(dangling_ends) = 1;

% Plot graph, marking dangling ends
% h = plot(giant_graph,'Layout','Force')
% highlight(h, dangling_ends, 'NodeColor','g')

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % FIND DANGLING TREES OF GIANT         %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Dangling trees are members of biconnected components.
% % NOT YET IMPLEMENTED.
% [a,C] = biconnected_components(giant_A);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN CLASSIFICATION ALGORITHMS        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SDP classifier.
% class_sdp = sdp_classifier(sbm);
% [agree_sdp,perm_sdp]= sbm.giant_classification_agreement(class_sdp);

% NB-walk classifier / ABP classifier.
class_nb = nb_classifier(sbm);
[agree_nb,perm_nb] = sbm.giant_classification_agreement(class_nb);

% Randwalk classifier.
[class_randwalk,V,D] = randwalk_classifier(sbm);
[agree_randwalk,perm_randwalk] = sbm.giant_classification_agreement(class_randwalk);

% adj2gephilab('test_sbm',sbm.get_adj_matrix(),'community',sbm.community,'class_nb',class_nb,'class_randwalk',class_randwalk,'dangling_end', dangling_mask,'in_giant',giant_mask);

disp(['Agree_nb: ' num2str(agree_nb)]);
disp(['Agree_randwalk: ' num2str(agree_randwalk)]);
disp(['Agree_sdp: ' num2str(agree_sdp)]);
val(i,1) = agree_nb;
val(i,2) = agree_randwalk;
val(i,3) = agree_sdp;
end