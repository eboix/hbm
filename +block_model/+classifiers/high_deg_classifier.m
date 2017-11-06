function class = high_deg_classifier(obj)
    % obj is a hybrid_block_model or graph or adj matrix object.
    % Find two highest-deg vertices and split remaining vertices by
    % distance to these vertices.
    % TODO DOES NOT DEPEND ON obj.k.
    
    disp('Running high_deg_classifier');

    [giant_A,giant_mask,~] = get_giant_adj_matrix_from_obj(obj);
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