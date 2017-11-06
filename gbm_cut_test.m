n = 20000;
c = 15;
thresh = c / sqrt(n);
obj = hybrid_block_model(n, [1 1], 1, [0 -1; 0 1], thresh, 0);

[giant_A,giant_mask,giant_rev,A,sparseg] = obj.get_giant_adj_matrix();
giant_n = length(giant_A);

[class, V, D] = randwalk_classifier(obj,giant_A,giant_rev);

[agreement, ~] = obj.classification_agreement(class);
res = agreement*n/giant_n;

