function class = sdp_classifier(obj,giant_A,giant_mask)
    % obj is a hybrid_block_model object.
    % Optional giant_A and giant_rev arguments.
    % Use SDP to split vertices.
    % TODO DOES NOT DEPEND ON obj.k.

    assert(nargin == 1 || nargin == 3);
    
    disp('Running sdp_classifier');
    if nargin == 1
        [giant_A,giant_mask,~,~,~] = get_giant_adj_matrix(obj);
    end
    n = obj.n;
    giant_n = length(giant_A);

    % X = argmax_{X psd, X_ii = 1} tr(B X),
    % where B is zero-one adj matrix.
%     B = -1*ones(giant_n);
%     B(giant_A == 1) = 1;

% X = argmax_{X psd, X_{i,i} = 1, X 1^n = 0}
    disp('Starting sdp');
    cvx_begin sdp
        variable X(giant_n,giant_n) semidefinite
        maximize(trace(giant_A*X))
        X*ones(giant_n,1) == 0
        diag(X) == 1
    cvx_end
    
    [C,~,~]=kmeans(X,obj.k,'replicates',10);
    
    class = zeros(n,1);
    class(giant_mask) = C;
        
end
