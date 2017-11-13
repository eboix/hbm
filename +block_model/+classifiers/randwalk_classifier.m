function [class,V,D] = randwalk_classifier(obj,varargin)
% obj is a hybrid_block_model object.
% Use second eigval of D^(-1) A to split vertices.
% TODO DOES NOT DEPEND ON obj.k.

% disp('Running randwalk_classifier');

function [classeigvec,vout] = randwalk_helper(giant_A,k)
    deg = sum(giant_A,1);
    degi = 1./deg;
    giant_size = size(giant_A);
    giant_n = giant_size(1);
    rand_walk = spdiags(degi',0,giant_n,giant_n) * giant_A;
    
    opts.tol = 1e-14;
    [Vv,Dd,flag] = eigs(rand_walk,k,'lr',opts);
    if flag
        error('Randwalk eigenvalues did not all converge.')
    end
    
    vout = cell(1,2);
    vout{1} = Vv;
    vout{2} = Dd;
    classeigvec = Vv(:,2:k);
end

[class,vout] = base_giant_classifier(@randwalk_helper, obj, varargin{:});
V = vout{1};
D = vout{2};








end
