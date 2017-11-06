function [clean_A,clean_mask,clean_rev] = clean_graph(A,c)
% A is adjacency matrix. c is algorithm parameter.

    original_n = size(A,1);

    % Cleaning algorithm.
    % 1. Delete all small components from G.
    [giant_A,~,giant_rev] = get_giant_adj_matrix_from_adj_matrix(A);
    
    giant_graph = graph(giant_A,'upper');
    diam_approx = max(distances(giant_graph,1)); % 2-approximation of the diameter.
    r_clean = c * (log(diam_approx))^3
    
    % 2. Repeat the following until it does not delete any vertices.
    new_num_nodes = size(giant_A,1);
    old_num_nodes = new_num_nodes + 1;
    iter = 0;
    while (old_num_nodes > new_num_nodes) && (new_num_nodes > 0)
        iter = iter + 1;
%         plot(graph(giant_A));
%         close all
        old_num_nodes = new_num_nodes;
        
        % a) Delete all leaves from G.
        deg = sum(giant_A,1);
        not_prune = find(deg ~= 1);
        giant_rev = giant_rev(not_prune);
        giant_A = giant_A(not_prune,not_prune);
        
        % b) If G has a vertex v, such that every vertex within sqrt(r) edges
        % of v has degree 2 or less, delete v.
        deg = sum(giant_A,1);
        srcs = find(deg > 2);
        if ~isempty(srcs)
            n = length(deg);
            giant_graph = graph(giant_A,'upper');
            giant_graph = addnode(giant_graph,n+1);
            giant_graph = addedge(giant_graph, (n+1)*ones(1,length(srcs)), srcs, ones(1,length(srcs)));
            dists = distances(giant_graph,n+1);
            not_prune = find(0 < dists & dists <= sqrt(r_clean));
            
            giant_rev = giant_rev(not_prune);
            giant_A = giant_A(not_prune,not_prune);
        end
        
        new_num_nodes = size(giant_A,1);
    end
    
    clean_A = giant_A;
    clean_rev = giant_rev;
    clean_mask = zeros(1,original_n);
    clean_mask(clean_rev) = 1;
end