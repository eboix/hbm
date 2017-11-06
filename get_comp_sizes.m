function [sbincount, comp] = get_comp_sizes(sparseg)
    % Returns component sizes of graph sparseg in descending order, and
    % index array of vertex to component. 1 is largest comp,
    % length(sbincount) is smallest component.
    
    comp = conncomp(sparseg);
    binrange = 1:max(comp);
    bincount = histc(comp, binrange);
    [sbincount, idx] = sort(bincount, 'descend');
    inv_idx(idx) = 1:length(idx); % Invert permutation.
    comp = inv_idx(comp);
end