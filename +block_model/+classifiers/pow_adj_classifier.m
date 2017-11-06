function [class_guess,vout] = pow_classifier(obj,varargin)
% obj is hybrid_block_model object, graph object, or adjacency matrix to
% cluster using the adjacency matrix of the powered graph.
% Optional parameters:
%   use_kmeans: if 1, use k-means to split into k communities.
%               else, sort values and divide in half.
%   k: number of clusters for the powering phase of the algorithm.
%      Optional if obj is an object with property obj.k.
%   clean_c: constant for the cleaning phase of the algorithm. Default is
%             0.1.
%   pow_c: constant for the powering phase of the algorithm. Default is
%          0.1.
% vout is unchanged extra output from adj_classifier.

    import block_model.classifiers.*;
    [class_guess,vout] = pow_classifier(@adj_classifier,obj,varargin{:});
end