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
    addParameter(p, 'no_clean',false, @(x) islogical(x));
    addParameter(p, 'clean_c',2,@(x) (isnumeric(x) && isscalar(x)));
    addParameter(p, 'pow_c',0.15,@(x) (isnumeric(x) && isscalar(x)));
    addParameter(p, 'k',-1,@(x) (isnumeric(x) && isscalar(x) && x > 0));
    parse(p,varargin{:});
    
    [giant_A,~,giant_rev] = get_giant_adj_matrix_from_obj(obj);
    
    if ~no_clean
    [clean_A,clean_mask,clean_rev] = clean_graph(giant_A,p.Results.clean_c);
    giant_to_clean = cumsum(clean_mask);
    giant_closest_in_clean = find_closest_vertices_to(graph(giant_A),clean_rev);
    giant_closest_in_clean = giant_to_clean(giant_closest_in_clean);
    else
        clean_A = giant_A;
        giant_closest_in_clean = 1:size(giant_A,1);
    end
    
    pow_A = pow_graph(clean_A,p.Results.pow_c);
    
    [n, obj_k] = get_n_and_k_from_obj(obj);
    k = obj_k;
    if obj_k == -1;
        k = p.Results.k;
        if p.Results.k == -1
            error('Have to specify k either in obj or as a parameter.');
        end
    end
    
    % pow_class_guess should be clean_n x 1.
    [pow_class_guess,vout] = class_func(pow_A,'use_kmeans',p.Results.use_kmeans,'k',k);
    giant_class_guess = pow_class_guess(giant_closest_in_clean);
    class_guess = zeros(n,1);
    for i = 1:k
        class_guess(giant_rev(giant_class_guess == i)) = i;
    end    
    
end