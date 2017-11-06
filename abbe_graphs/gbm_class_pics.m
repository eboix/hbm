function gbm_class_pics(class_func,class_name,n_vals,num_trials)

if nargin == 0
    adj_gbm_pics;
    return
end

import block_model.utility.*;
import block_model.hybrid_block_model;
import export_fig.*;


if nargin < 4
    num_trials = 10;
end
if nargin < 3
    n_vals = [10000 20000];
end

% agree_val = zeros(length(n_vals),num_trials);
figfiles = {};

tempdir = 'tmpfiles';
clear_and_create_tempdir(tempdir);

% KS-threshold is (a-b)^2 / (2(a+b)) > 1.
% So given a > 2, we can calculate the threshold value for b.
c = 10;
d = 2;

for ni = 1:length(n_vals)
    n = n_vals(ni)
    thresh = c/sqrt(n);
    
    for i = 1:num_trials
        i
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % INSTANTIATE GBM MODEL                %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        community_rel_sizes = [1 1];
        GBM_MODEL = 1;
        sbm_junk = -1; % Parameters not needed for pure GBM.
        center = [[0 0]; [d 0]];
        gbm = hybrid_block_model(n,community_rel_sizes,GBM_MODEL,center,thresh,sbm_junk);
        
        % [giant_A,giant_mask,giant_rev] = sbm.get_giant_adj_matrix();
        % giant_graph = graph(giant_A);
        
        % Run Classifier
        class_guess = class_func(gbm);
        [agree_class,~] = gbm.giant_classification_agreement(class_guess);
        
        num_class = zeros(1,2);
        for j = 1:2
            num_class(j) = sum(class_guess == j);
        end
        [vs, is] = min(num_class);
        gbm_graph = gbm.get_graph();
        verts = find(class_guess == is);
        fh = figure;
        gbm.plot_classifications(class_guess);
        figtitle = sprintf('\\parbox{4in}{\\centering \\textbf{%s classifier} \\\\ $\\log_{10}{n} = %.3f$, agreement = $%.4f$}\n\n', class_name, log10(n), agree_class)
        p = mtit(fh, figtitle);
        p.th.Interpreter = 'latex';
        p.th.FontSize = 14;
        
        filename = fullfile(tempdir,sprintf([class_name '_%d_%d.pdf'],n,i));
        set(gcf, 'PaperPositionMode', 'auto');
        set(gcf, 'PaperOrientation', 'landscape');
        print(gcf,'-dpdf',filename);
      %  export_fig(filename);
        figfiles = [figfiles {filename}];
        close all
        % agree_val(ni,i) = agree_class;
    end
end

try
    status = system(['"/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o ' class_name '_gbm_out.pdf ' strjoin(figfiles, ' ')]);
    if status
        error('Command did not work.');
    end
catch
    append_pdfs([class_name '_gbm_out.pdf'],figfiles{:});
end
end