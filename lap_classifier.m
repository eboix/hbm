function [class,V,D] = lap_classifier(obj,giant_A,giant_rev)
    % obj is a hybrid_block_model object.
    % Optional giant_A and giant_rev arguments.
    % Use eigvals of D - A to split vertices.
    % TODO DOES NOT DEPEND ON obj.k.

    assert(nargin == 1 || nargin == 3);
    
    classeigvecnum = 2;
    disp(sprintf('Running lap_classifier on eigvec #%d', classeigvecnum));
    
    if nargin == 1
        [giant_A,~,giant_rev,~,~] = get_giant_adj_matrix(obj);
    end
    n = obj.n;
    giant_n = length(giant_A);

    deg = sum(giant_A,1);
    giant_lap = spdiags(deg',0,giant_n,giant_n) - giant_A;
    numcalculate = 2;
    [V,D] = eigs(giant_lap,2,'sm');
    classeigvec = V(:,numcalculate-classeigvecnum+1);
    [~,idx] = sort(classeigvec);
    class = zeros(n,1);
    class(giant_rev(idx(1:floor(giant_n/2)))) = 1;
    class(giant_rev(idx(floor(giant_n/2):end))) = 2;
        
end