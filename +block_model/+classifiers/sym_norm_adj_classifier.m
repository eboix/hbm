function [class,V,D] = sym_norm_adj_classifier(obj,varargin)
    % obj is a hybrid_block_model object.
    % Use second largest eigval of D^{-1/2} A D^{-1/2} (in magnitude) to split vertices.
    
  %  disp('Running sym_norm_adj_classifier');
    
    function [classeigvec,vout] = sym_norm_adj_helper(giant_A,k)
        deg = sum(giant_A,1);
        degi = sqrt(1./deg);
        giant_n = length(deg);
        sdegi = spdiags(degi', 0, giant_n, giant_n);
        sym_norm_adj = sdegi * giant_A * sdegi;
    
        [Vv,Dd] = eigs(sym_norm_adj,k,'lr');
        % MATLAB DOES NOT AUTOMATICALLY SORT EIGS IN R2017a AND BELOW:
        [Dd,I] = sort(diag(Dd),'descend');
        Vv = Vv(:,I);
        
        vout{1} = Vv;
        vout{2} = Dd;
        classeigvec = Vv(:,2:k);
    end

    [class,vout] = base_giant_classifier(@sym_norm_adj_helper, obj, varargin{:});
    V = vout{1};
    D = vout{2};
        
end
