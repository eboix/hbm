function [class,V,D] = graph_pow_adj_classifier(obj,graph_pow,giant_A,giant_rev)
    % obj is a hybrid_block_model object.
    % Optional giant_A and giant_rev arguments.
    % Use second eigval of A to split vertices.
    % TODO DOES NOT DEPEND ON obj.k.

    assert(nargin == 1 || nargin == 4);
    
 %   disp('Running adj_classifier');
    if nargin == 1
        [giant_A,~,giant_rev,~,~] = get_giant_adj_matrix(obj);
    end
    n = obj.n;
    giant_n = length(giant_A);
    A_pow = giant_A^graph_pow;
    A_pow(A_pow ~= 0) = 1;
    [V,D] = eigs(A_pow,2);

    classeigvec = V(:,2);
    [~,idx] = sort(classeigvec);
    class = zeros(n,1);
    class(giant_rev(idx(1:floor(giant_n/2)))) = 1;
    class(giant_rev(idx(floor(giant_n/2):end))) = 2;
        
end
