function [class,V,D] = graph_pow_adj_classifier(obj,graph_pow,giant_A,giant_rev)
    % obj is a hybrid_block_model object.
    % Optional giant_A and giant_rev arguments.
    % Use second eigval of A to split vertices, after powering to the
    % graph_powth power.
    % TODO DOES NOT DEPEND ON obj.k.

    assert(nargin == 2 || nargin == 4);
    
    disp('Running graph_pow_adj_classifier');
    if nargin == 2
        [giant_A,~,giant_rev,~,~] = get_giant_adj_matrix(obj);
    end
    n = obj.n;
    
    giant_n = length(giant_A);
    A_pow = giant_A^graph_pow;
    A_pow(A_pow ~= 0) = 1;
    A_pow(1:(giant_n+1):end) = 0;
    
    try
        [V,D] = eigs(A_pow,2);
    catch
        warning('eigs had a problem');
        class = zeros(n,1);
        V = zeros(n,1);
        D = 0;
        return
    end
    
    classeigvec = V(:,2);
    
    global USE_KMEANS
    if USE_KMEANS
        C = kmeans(classeigvec,obj.k,'replicates',10);
        class = zeros(n,1);
        class(giant_rev(C == 1)) = 1;
        class(giant_rev(C == 2)) = 2;
    else 
        [~,idx] = sort(classeigvec);
        class = zeros(n,1);
        class(giant_rev(idx(1:floor(giant_n/2)))) = 1;
        class(giant_rev(idx(floor(giant_n/2):end))) = 2;
    end
    
        
end
