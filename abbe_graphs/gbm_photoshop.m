import block_model.hybrid_block_model;
import block_model.classifiers.*;
import export_fig.*;

close all
figure
hold on

n = 10000;
d = 2;
c = 10;
thresh = c / sqrt(n);
community_rel_sizes = [1 1];
GBM_MODEL = 1;
sbm_junk = -1; % Parameters not needed for pure GBM.
center = [[0 0]; [d 0]];
gbm = hybrid_block_model(n,community_rel_sizes,GBM_MODEL,center,thresh,sbm_junk);

A = gbm.get_adj_matrix();
[~,giant_mask,giant_rev] = gbm.get_giant_adj_matrix();

% Run Classifier
% class_func = @adj_classifier;
% class_func = @lap_classifier;
% class_func = @nb_classifier;
class_func = @randwalk_classifier;
class_guess = class_func(gbm);
[agree_class,~] = gbm.giant_classification_agreement(class_guess);
disp('Ran classifier.');

 num_class = zeros(1,2);
for j = 1:2
    num_class(j) = sum(class_guess == j);
end
[vs, is] = min(num_class);

pos = gbm.pos;

for u = giant_rev
    nebs = find(A(u,:));
    for v = nebs
        if u < v
            line([pos(u,1) pos(v,1)], [pos(u,2) pos(v,2)], 'Color', [127 128 129]/255); % [0.8 0.8 0.8]
        end
    end
end

col_mat_face = [[60 100 200]/255;[216 33 32]/255; [34 124 43]/255; [160 84 161]/255];
% col_mat_face = [[40 103 239]/255;[220 27 29]/255; [36 130 45]/255]; % [0.89 0.99 0.89];

p = randperm(length(giant_rev));
for i = giant_rev(p)
    if ~giant_mask(i), continue; end
 %   if class_guess(i) == is
 %       plot(pos(i,1),pos(i,2),'.','Color',col_mat_face(3,:),'MarkerSize',25);
 %   else
        plot(pos(i,1),pos(i,2),'.','Color',col_mat_face(gbm.community(i),:),'MarkerSize',25);
 %   end
end

set(gcf, 'Position', get(0, 'Screensize'));
set(gcf, 'Color', [1 1 1])
axis equal
set(gca,'visible','off')
set(gcf, 'PaperPositionMode', 'auto');
set(gcf, 'PaperOrientation', 'landscape');
export_fig('orig_graph_picture.png');
close all

figure
hold on
for u = giant_rev
    nebs = find(A(u,:));
    for v = nebs
        if u < v
            line([pos(u,1) pos(v,1)], [pos(u,2) pos(v,2)], 'Color', [127 128 129]/255); % [0.8 0.8 0.8]
        end
    end
end

p = randperm(length(giant_rev));
for i = giant_rev(p)
    if ~giant_mask(i), continue; end
    if class_guess(i) == is
        plot(pos(i,1),pos(i,2),'.','Color',col_mat_face(3,:),'MarkerSize',25);
    else
        plot(pos(i,1),pos(i,2),'.','Color',col_mat_face(4,:),'MarkerSize',25);
    end
end

set(gcf, 'Position', get(0, 'Screensize'));
set(gcf, 'Color', [1 1 1])
axis equal
set(gca,'visible','off')
set(gcf, 'PaperPositionMode', 'auto');
set(gcf, 'PaperOrientation', 'landscape');
export_fig('clustered_graph_picture.png');


% print(gcf, '-dpdf', 'example_graph_picture.pdf')

