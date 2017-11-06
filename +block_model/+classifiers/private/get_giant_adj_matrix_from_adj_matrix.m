function [giant_A,giant_mask,giant_rev] = get_giant_adj_matrix_from_adj_matrix(A)
    sparseg = graph(A);
    comp = conncomp(sparseg);
    binrange = 1:max(comp);
    bincount = histc(comp, binrange);
    [~, idx] = sort(bincount, 'descend');
    inv_idx(idx) = 1:length(idx); % Invert permutation.
    comp = inv_idx(comp);

    giant_mask = (comp == 1);
    giant_rev = find(giant_mask);
    giant_A = A(giant_mask, giant_mask);
end