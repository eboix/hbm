function [class_guess,vout] = pow_classifier(class_func,obj,varargin)
% class_func is classifier to run after powering.
% obj is hybrid_block_model object, graph object, or adjacency matrix to
% cluster.
% Optional parameters:
%   use_kmeans: if 1, use k-means to split into k communities.
%               else, sort values and divide in half.
%   k: number of clusters for the powering phase of the algorithm.
%      Optional if obj is an object with property obj.k.
%   clean_c: constant for the cleaning phase of the algorithm. Default is
%             0.1.
%   pow_c: constant for the powering phase of the algorithm. Default is
%          0.1.
% vout is unchanged extra output from class_func.

    p = inputParser;
    addParameter(p, 'use_kmeans',1,@(x) (isnumeric(x) && isscalar(x) && x == 0 || x == 1));
    addParameter(p, 'clean_c',2,@(x) (isnumeric(x) && isscalar(x)));
    addParameter(p, 'pow_c',0.15,@(x) (isnumeric(x) && isscalar(x)));
    addParameter(p, 'k',-1,@(x) (isnumeric(x) && isscalar(x) && x > 0));
    parse(p,varargin{:});
    
    [giant_A,~,giant_rev] = get_giant_adj_matrix_from_obj(obj);
    [clean_A,~,clean_rev] = clean_graph(giant_A,p.Results.clean_c);
    
    giant_n = size(giant_A,1);
    clean_n = size(clean_A,1);
    closest_in_giant = zeros(giant_n,1);
    closest_in_giant(clean_rev) = clean_rev;
    vis = zeros(giant_n,1);
    vis(clean_rev) = 1;
    % DFS to find the closest in the giant. (DFS suffices, because of the
    % structure of the pruned subgraph.)
    
    
    clean_rev = giant_rev(clean_rev);
    pow_A = pow_graph(clean_A,p.Results.pow_c);
    
    [n, obj_k] = get_n_and_k_from_obj(obj);
    k = obj_k;
    if obj_k == -1;
        k = p.Results.k;
        if p.Results.k == -1
            error('Have to specify k either in obj or as a parameter.');
        end
    end
    
    % clean_class_guess should be clean_n x K for some K.
    [clean_class_guess,vout] = class_func(pow_A,'use_kmeans',p.Results.use_kmeans,'k',k);
    
    class_guess = zeros(n,1);
    for i = 1:k
        class_guess(clean_rev(clean_class_guess == i)) = i;
    end    
    
end