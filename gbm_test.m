n = 100000
a = 1;
b = 0.5;
thresh = 1/sqrt(n);
obj = gbm(n, [1 1], thresh, [a b; b a], 2, 'cube');
A = obj.get_adj_matrix();

% obj.plot_classifications(obj.community);

figure
xrange = 1:obj.n_community(1);
yrange = (obj.n_community(1) + 1):obj.n;
% yrange = xrange;
outA = A^200;
outA = outA(xrange,:);
outA = outA(:,yrange);

[~, idx1] = sortrows(obj.pos(xrange,:));
outA = outA(idx1,:);
[~, idx2] = sortrows(obj.pos(yrange,:));
outA = outA(:,idx2);
spy(outA);