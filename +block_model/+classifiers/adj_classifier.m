function [class,V,D] = adj_classifier(obj,varargin)
% Use second eigval of A to cluster vertices of giant component.
% obj is a hybrid_block_model object, an adjacency matrix, or a graph
% object.
% Optional parameter:
%   use_kmeans: if 1, use k-means to split into k communities.
%               else, sort values and divide in half.
%                     TODO: THIS DOES NOT YET DEPEND ON obj.k.


function [classeigvec,vout] = adj_helper(giant_A,k)
    [Vv,Dd] = eigs(giant_A,k,'la');
    % MATLAB DOES NOT AUTOMATICALLY SORT EIGS IN R2017a AND BELOW:
    [Dd,I] = sort(diag(Dd),'descend');
    Vv = Vv(:,I);
    
    vout{1} = Vv;
    vout{2} = Dd;
    classeigvec = Vv(:,2:k);
end

[class,vout] = base_giant_classifier(@adj_helper, obj, varargin{:});
V = vout{1};
D = vout{2};

end
