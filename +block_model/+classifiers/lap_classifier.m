function [class,V,D] = lap_classifier(obj,varargin)
% Use second eigval of D - A to cluster vertices of giant component.
% obj is a hybrid_block_model object.
% Optional parameter:
%   use_kmeans: if 1, use k-means to split into k communities.
%               else, sort values and divide in half.
%                     TODO: THIS DOES NOT YET DEPEND ON obj.k.


function [classeigvec,vout] = lap_helper(giant_A,k)
    deg = sum(giant_A,1);
    giant_n = length(deg);
    giant_lap = spdiags(deg',0,giant_n,giant_n) - giant_A;
    [Vv,Dd] = eigs(giant_lap,k,'sm');
    % MATLAB DOES NOT AUTOMATICALLY SORT EIGS IN R2017a AND BELOW:
    [Dd,I] = sort(diag(Dd),'ascend');
    Vv = Vv(:,I);
    
    vout{1} = Vv;
    vout{2} = Dd;
    classeigvec = Vv(:,2:k);
end

[class,vout] = base_giant_classifier(@lap_helper, obj, varargin{:});
V = vout{1};
D = vout{2};

end
