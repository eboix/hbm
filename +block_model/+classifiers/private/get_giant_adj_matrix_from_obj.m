function [giant_A,giant_mask,giant_rev] = get_giant_adj_matrix_from_obj(obj)
    if isa(obj,'block_model.hybrid_block_model') % Hybrid block model.
        [giant_A,giant_mask,giant_rev] = get_giant_adj_matrix(obj);
    elseif isa(obj,'graph') % Graph.
        [giant_A,giant_mask,giant_rev] = get_giant_adj_matrix_from_graph(obj);
    else
        [giant_A,giant_mask,giant_rev] = get_giant_adj_matrix_from_adj_matrix(obj);
    end
end