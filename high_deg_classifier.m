function class = high_deg_classifier(obj,giant_A,giant_mask)
    % obj is a hybrid_block_model object.
    % Optional giant_A and giant_rev arguments.
    % Use second eigval of D^(-1) A to split vertices.
    % TODO DOES NOT DEPEND ON obj.k.

    assert(nargin == 1 || nargin == 3);
    
    disp('Running high_deg_classifier');
    
    if nargin == 1
        [giant_A,giant_mask,~,~,~] = get_giant_adj_matrix(obj);
    end
    n = obj.n;
    giant_n = length(giant_A);

    giantg = graph(giant_A);
    degs = sum(giant_A,1);
    [~,idx] = sort(degs);
    s = [idx(end) idx(end-1)];
    d = distances(giantg, s);

    % CLASSIFY: 1 is cluster 1, 2 is cluster 2, 0 is equal distance....
    % unspecified cluster.
    class_giant = zeros(giant_n,1);
    class_giant(d(1,:) < d(2,:)) = 1;
    class_giant(d(2,:) < d(1,:)) = 2;
    eqvals = (d(1,:) == d(2,:));
    class_giant(eqvals) = randi(2,1,sum(eqvals)); % Randomly assign equal distance points.

    class = zeros(n,1);
    class(giant_mask) = class_giant;
        
end