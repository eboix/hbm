function [class,V,D] = sym_norm_lap_classifier(obj,varargin)
% Use second eigval of I - D^{-1/2}AD^{1/2} to cluster vertices of giant component.
% obj is a hybrid_block_model object.
% Optional parameter:
%   use_kmeans: if 1, use k-means to split into k communities.
%               else, sort values and divide in half.
%                     TODO: THIS DOES NOT YET DEPEND ON obj.k.


function [classeigvec,vout] = sym_norm_lap_helper(giant_A)
    deg = sum(giant_A,1);
    degi = sqrt(1./deg);
    giant_n = length(deg);
    Dmhalf = spdiags(degi',0,giant_n,giant_n);
    giant_sym_norm_lap = speye(giant_n) - Dmhalf * giant_A * Dmhalf;
    [Vv,Dd] = eigs(giant_sym_norm_lap,2,'sm');
    % MATLAB DOES NOT AUTOMATICALLY SORT EIGS IN R2017a AND BELOW:
    [Dd,I] = sort(diag(Dd),'ascend');
    Vv = Vv(:,I);
    
    vout{1} = Vv;
    vout{2} = Dd;
    classeigvec = Vv(:,2);
end

[class,vout] = base_giant_classifier(@sym_norm_lap_helper, obj, varargin{:});
V = vout{1};
D = vout{2};

end
