function [n,k] = get_n_and_k_from_obj(obj)
    if isa(obj,'block_model.hybrid_block_model') % Hybrid block model.
        n = obj.n;
        k = obj.k;
    elseif isa(obj,'graph') % Graph.
        n = height(obj.Nodes);
        k = -1;
    else
        n = size(obj,1);
        k = -1;
    end
end