function [class,V,D] = graph_pow_adj_classifier(obj,graph_pow,varargin)
    % obj is a hybrid_block_model object.
    % graph_pow is a natural number.
    % Use second eigval of A to split vertices, after powering to the
    % graph_powth power.
    % Optional use_kmeans parameter.
    
    disp('Running graph_pow_adj_classifier');

    function [classeigvec,vout] = graph_pow_adj_helper(obj2,graph_pow2)
        n = obj2.n;
        
        [giant_A,~,~] = get_giant_adj_matrix(obj2);
        A_pow = giant_A^graph_pow2;
        A_pow(A_pow ~= 0) = 1; % Threshold.
        A_pow(1:(giant_n+1):end) = 0; % Diagonal entries.
        
        try
            [Vv,Dd] = eigs(A_pow,2);
            classeigvec = Vv(:,2);
        catch
            warning('eigs had a problem');
            classeigvec = zeros(n,1);
            Vv = zeros(n,1);
            Dd = 0;
        end
        vout{1} = Vv;
        vout{2} = Dd;
    end

    fh = @(x) graph_pow_adj_helper(x,graph_pow);
    [class,vout] = base_giant_classifier(fh, obj, varargin{:});
    V = vout{1};
    D = vout{2};
        
end
