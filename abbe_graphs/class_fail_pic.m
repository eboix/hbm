function class_fail_pic(class_func,class_name,n,a,b)

if nargin == 0
    photoshop_graph
    return
end

if n < 1000
    warning('Use on large graphs, because the photoshop is more evident when you input a small graph.');
end

import block_model.hybrid_block_model;
import block_model.classifiers.*;
import export_fig.*;

% n will be large. Let us see how large we can do the photoshop.

community_rel_sizes = [1 1];
SBM_MODEL = 0;
gbm_junk = -1; % Parameters not needed for pure SBM.
Q = [a b; b a]/n;
sbm = hybrid_block_model(n,community_rel_sizes,SBM_MODEL,gbm_junk,gbm_junk,Q);
A = sbm.get_adj_matrix();
class_guess = class_func(sbm);
[agree_class,~] = sbm.giant_classification_agreement(class_guess);

num_class = zeros(1,2);
for j = 1:2
    num_class(j) = sum(class_guess == j);
end
[vs, is] = min(num_class);
if vs > 1000
    return
end

sbm_graph = sbm.get_graph();
verts = find(class_guess == is);
neighbs = [];
for j = 1:length(verts)
    neighbs = [neighbs; neighbors(sbm_graph,verts(j))];
end
neighbs = setdiff(unique(neighbs), verts);

extended_verts = [verts; neighbs];
small_n = length(extended_verts);
spec_pos = normrnd(0,1,small_n,2);
for i = 1:small_n
   if sbm.community(extended_verts(i)) == 1
       spec_pos(i,1) = spec_pos(i,1) + 5;
   end
end
Ap = A(extended_verts,:);
Ap = Ap(:,extended_verts);

disp('Classification computed.');

close all

figure
hold on

n = min(1000,n);
Q = [a b; b a]/n;
sbm = hybrid_block_model(n,community_rel_sizes,SBM_MODEL,gbm_junk,gbm_junk,Q);
A = sbm.get_adj_matrix();

pos = normrnd(0,1,n,2);
n1 = sbm.n_community(1);
pos(1:n1,1) = pos(1:n1,1) + 5 * ones(n1,1);

A = sbm.get_adj_matrix();
[~,giant_mask,giant_rev] = sbm.get_giant_adj_matrix();

% % Only plot a subgraph of a certain density, so that you're plotting about
% % 10000 guys tops.
% subg = rand(n,1);
% subgmask = (subg < 1000/n);
% rang = 1:n;
% subg = rang(subgmask);

for u = giant_rev
    nebs = find(A(u,:));
    for v = nebs
        if u < v
            line([pos(u,1) pos(v,1)], [pos(u,2) pos(v,2)], 'Color', [0.9 0.9 0.9]);
        end
    end
end

for i = giant_rev
    if ~giant_mask(i), continue; end
    plot(pos(i,1),pos(i,2),'.','Color',[0 0 0],'MarkerSize',10);
end

for u = 1:length(extended_verts)
    nebs = find(Ap(u,:));
    for v = nebs
        line([spec_pos(u,1) spec_pos(v,1)], [spec_pos(u,2) spec_pos(v,2)], 'Color', [161 204 255]/255, 'LineWidth', 2);
    end
end

for i = 1:length(verts)
    plot(spec_pos(i,1),spec_pos(i,2),'.','Color',[1 0 0],'MarkerSize',20);
end


for i = length(verts)+1:length(extended_verts)
    plot(spec_pos(i,1),spec_pos(i,2),'.','Color',[0 1 0],'MarkerSize',20);
end

print(gcf, '-dpdf', 'example_graph_picture.pdf')

end
