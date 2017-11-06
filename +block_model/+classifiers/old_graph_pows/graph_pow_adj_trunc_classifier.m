function [class,V,D] = graph_pow_adj_trunc_classifier(obj,graph_pow,giant_A,giant_rev)
    % obj is a hybrid_block_model object.
    % Optional giant_A and giant_rev arguments.
    % Use second eigval of A to split vertices, after iteratively powering to the
    % graph_powth power and truncating on each step as well.
    % TODO DOES NOT DEPEND ON obj.k.

    assert(nargin == 2 || nargin == 4);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WE WILL ITERATIVELY POWER AND SUBSAMPLE. WE ALLOW
    % THE NUMBER OF EDGES TO GO UP TO AS MANY some constant*THE ORIGINAL NUMBER OF EDGES.
    % THIS IS PRETTY ARBITRARY. WE SUBSAMPLE REGULARLY TO KEEP A BOUND ON THE TOTAL # OF
    % EDGES.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp('Running graph_pow_adj_trunc_classifier');
    if nargin == 2
        [giant_A,~,giant_rev,~,~] = get_giant_adj_matrix(obj);
    end
    
    giant_n = length(giant_A);
    orig_e = sum(sum(giant_A))/2;
    e_bound = 4*orig_e;
    
    n = obj.n;

    A_pow = giant_A;
    % UNIFORM SUBSAMPLING.
    for iter = 2:graph_pow
        A_pow = giant_A*A_pow;
        A_pow = triu(A_pow,1);
        [row, col]= find(A_pow);
        pos = sub2ind(size(A_pow), row, col);
        numnonzero = length(row);
        thresh = min(numnonzero, e_bound)/numnonzero;
        pos_remove = pos(rand(numnonzero,1) > thresh);
        A_pow(pos_remove) = 0;
        A_pow(A_pow ~= 0) = 1;
        A_pow = A_pow + A_pow';
    end

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
