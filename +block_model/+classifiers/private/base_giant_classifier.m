function [class_guess,vout] = base_giant_classifier(class_func,obj,varargin)
% class_func is classifier helper function used to classify obj.
% obj is hybrid_block_model, graph, or adjacency matrix.
% Optional parameter:
%   use_kmeans: if 1, use k-means to split into k communities.
%               else, sort values and divide in half.
%                     TODO: THIS DOES NOT YET DEPEND ON obj.k.
%   k: if specified, # of communities in which to cluster the graph. Else
%      use obj.k if applicable. Should be specified if 

    p = inputParser;
    addParameter(p, 'use_kmeans',1,@(x) (isnumeric(x) && isscalar(x) && x == 0 || x == 1));
    addParameter(p, 'k',-1,@(x) (isnumeric(x) && isscalar(x) && x > 0));
    parse(p,varargin{:});
    
    [n, k] = get_n_and_k_from_obj(obj);
    if k == -1
        if p.Results.k == -1
            error('Have to specify k either in obj or as a parameter.');
        else
            k = p.Results.k;
        end
    end
    
    [giant_A,~,giant_rev] = get_giant_adj_matrix_from_obj(obj);
    
    [classeigvec,vout] = class_func(giant_A,k);
    % classeigvec should be giant_n x K for some K.

    giant_n = length(giant_rev);

    if p.Results.use_kmeans
        C = kmeans(classeigvec,k,'replicates',10);
        class_guess = zeros(n,1);
        for i = 1:k
            class_guess(giant_rev(C == i)) = i;
        end
    else
        if k ~= 2
            error('Use kmeans to cut into > 2 communities.');
        end
        [~,idx] = sort(classeigvec);
        class_guess = zeros(n,1);
        class_guess(giant_rev(idx(1:floor(giant_n/2)))) = 1;
        class_guess(giant_rev(idx(floor(giant_n/2):end))) = 2;
    end
end