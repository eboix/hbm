function [class,V,D] = graph_pow_lap_classifier(obj,graph_pow,giant_A,giant_rev)
    % obj is a hybrid_block_model object.
    % Optional giant_A and giant_rev arguments.
    % Use eigvals of D - A to split vertices, after powering to the
    % graph_powth power.
    % TODO DOES NOT DEPEND ON obj.k.

    assert(nargin == 2 || nargin == 4);
    
    classeigvecnum = 2;
    disp(sprintf('Running graph_pow_lap_classifier on eigvec #%d', classeigvecnum));
    
    if nargin == 2 
        [giant_A,~,giant_rev,~,~] = get_giant_adj_matrix(obj);
    end
    n = obj.n;
    giant_n = length(giant_A);
    A_pow = giant_A^graph_pow;
    A_pow(A_pow ~= 0) = 1;
    A_pow(1:(giant_n+1):end) = 0;
    
    deg = sum(A_pow,1);
    giant_lap = spdiags(deg',0,giant_n,giant_n) - A_pow;
    
    numcalculate = 2;
    [V,D] = eigs(giant_lap,2,'sm');
    classeigvec = V(:,numcalculate-classeigvecnum+1);
    [~,idx] = sort(classeigvec);
    class = zeros(n,1);
    class(giant_rev(idx(1:floor(giant_n/2)))) = 1;
    class(giant_rev(idx(floor(giant_n/2):end))) = 2;
        
end
