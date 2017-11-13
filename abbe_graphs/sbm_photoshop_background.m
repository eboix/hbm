import block_model.hybrid_block_model;
import block_model.classifiers.*;
import export_fig.*;

a = 2.2;
b = -sqrt(4*a + 1) + a + 1;
a = a - 0.01; % Go slightly below KS threshold, so recovery is possible at large n.

close all
figure
hold on

n = 10000;
Q = [a b; b a]/n;
gbm_junk = -1;
community_rel_sizes = [1 1];
SBM_MODEL = 0;
sbm = hybrid_block_model(n,community_rel_sizes,SBM_MODEL,gbm_junk,gbm_junk,Q);

pos = normrnd(0,1,n,2);
n1 = sbm.n_community(1);
pos(1:n1,1) = pos(1:n1,1) + 7 * ones(n1,1);

A = sbm.get_adj_matrix();
[~,giant_mask,giant_rev] = sbm.get_giant_adj_matrix();


for u = giant_rev
    nebs = find(A(u,:));
    for v = nebs
        if u < v
            line([pos(u,1) pos(v,1)], [pos(u,2) pos(v,2)], 'Color', [110 110 110]/255);
        end
    end
end

col_mat_face = [[40 103 239]/255;[228 26 27]/255];
% col_mat_face = [[0.45 0.45 0.98]; [0.98 0.45 0.45]; [0.984 0.776 0.776]]; % [0.89 0.99 0.89];
col_mat_edge = [[0.04 0.38 0.04]; [0.491 0.007 0.007]];

for i = giant_rev
    if ~giant_mask(i), continue; end
    plot(pos(i,1),pos(i,2),'.','Color',col_mat_face(sbm.community(i),:),'MarkerSize',25);
end

set(gcf, 'Position', get(0, 'Screensize'));
set(gcf, 'Color', [1 1 1])
axis equal
set(gca,'visible','off')
set(gcf, 'PaperPositionMode', 'auto');
set(gcf, 'PaperOrientation', 'landscape');
export_fig('example_graph_picture.png');
% print(gcf, '-dpdf', 'example_graph_picture.pdf')

