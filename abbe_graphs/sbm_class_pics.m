function sbm_class_pics(class_func, class_name,n_vals,num_trials)

import block_model.utility.*;
import block_model.hybrid_block_model;
import export_fig.*;


if nargin < 4
    num_trials = 10;
end
if nargin < 3
    n_vals = [100000 200000];
end

% agree_val = zeros(length(n_vals),num_trials);
figfiles = {};

tempdir = 'tmpfiles';
clear_and_create_tempdir(tempdir);

% KS-threshold is (a-b)^2 / (2(a+b)) > 1.
% So given a > 2, we can calculate the threshold value for b.
a = 2.2;
b = -sqrt(4*a + 1) + a + 1;
a = a - 0.01; % Go slightly below KS threshold, so recovery is possible at large n.

for ni = 1:length(n_vals)
    n = n_vals(ni)
    
    for i = 1:num_trials
        i
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % INSTANTIATE SBM MODEL                %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        community_rel_sizes = [1 1];
        SBM_MODEL = 0;
        gbm_junk = -1; % Parameters not needed for pure SBM.
        Q = [a b; b a]/n;
        sbm = hybrid_block_model(n,community_rel_sizes,SBM_MODEL,gbm_junk,gbm_junk,Q);
        
        % [giant_A,giant_mask,giant_rev] = sbm.get_giant_adj_matrix();
        % giant_graph = graph(giant_A);
        
        % Run Classifier
        class_guess = class_func(sbm);
        [agree_class,~] = sbm.giant_classification_agreement(class_guess);
        
        num_class = zeros(1,2);
        for j = 1:2
            num_class(j) = sum(class_guess == j);
        end
        [vs, is] = min(num_class);
        sbm_graph = sbm.get_graph();
        verts = find(class_guess == is);
        fh = figure;
        plot_subgraph_and_neighbors(sbm_graph, verts);
        mtit(fh, sprintf('%s; log10(n) = %.4f; agreement = %f', class_name, log10(n), agree_class));
        filename = fullfile(tempdir,sprintf([class_name '_%d_%d.pdf'],n,i));
        
        export_fig(filename);
        figfiles = [figfiles {filename}];
        close all
        % agree_val(ni,i) = agree_class;
        
    end
end

append_pdfs([class_name '_sbm_out.pdf'],figfiles{:});
end