function [class,V,D] = randwalk_classifier(obj,giant_A,giant_rev)
    % obj is a hybrid_block_model object.
    % Optional giant_A and giant_rev arguments.
    % Use second eigval of D^(-1) A to split vertices.
    % TODO DOES NOT DEPEND ON obj.k.

    assert(nargin == 1 || nargin == 3);
    
    disp('Running randwalk_classifier');
    
    if nargin == 1
        [giant_A,~,giant_rev,~,~] = get_giant_adj_matrix(obj);
    end
    n = obj.n;
    giant_n = length(giant_A);

    deg = sum(giant_A,1);
    degi = 1./deg;
    rand_walk = spdiags(degi',0,giant_n,giant_n) * giant_A;
    [V,D] = eigs(rand_walk,3);
    classeigvec = V(:,2);
    [~,idx] = sort(classeigvec);
    class = 3*zeros(n,1);
    class(giant_rev(idx(1:floor(giant_n/2)))) = 1;
    class(giant_rev(idx(ceil(giant_n/2):end))) = 2;

        
end