n = 100000;
c = 15;
d = 2;
a = -1;
b = -1;

thresh = c / sqrt(n);
obj = hybrid_block_model(n, [1 1], 1, [-d 0; d 0], thresh, [a b; b a]./n);
[giant_A,giant_mask,giant_rev,A,sparseg] = obj.get_giant_adj_matrix();

spt = shortestpathtree(sparseg, giant_rev(1));
plot(spt, 'XData', obj.pos(:,1), 'YData', obj.pos(:,2), 'EdgeColor','b', 'NodeColor', 'none')
