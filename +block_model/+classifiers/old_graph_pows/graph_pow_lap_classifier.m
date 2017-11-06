function [class,V,D] = graph_pow_lap_classifier(obj,graph_pow,varargin)
% obj is a hybrid_block_model object.
% Optional giant_A and giant_rev arguments.
% Use eigvals of D_pow - A_pow to split vertices, where A_pow is A powered
% to the (graph_pow)th power.
% TODO DOES NOT DEPEND ON obj.k.

    function [classeigvec,vout] = graph_pow_lap_helper(obj2,graph_pow2)
        
        classeigvecnum = 2;
        disp(sprintf('Running graph_pow_lap_classifier on eigvec #%d', classeigvecnum));
        
        n = obj2.n;
        
        [giant_A,~,~] = get_giant_adj_matrix(obj2);
        A_pow = giant_A^graph_pow2;
        A_pow(A_pow ~= 0) = 1; % Threshold.
        A_pow(1:(giant_n+1):end) = 0; % Diagonal entries.
        
        deg = sum(A_pow,1);
        giant_lap = spdiags(deg',0,giant_n,giant_n) - A_pow;
        
        if sum(sum(giant_lap ~= 0)) > 5e5
            warning('Not enough memory to do calculation')
            classeigvec = zeros(n,1);
            Vv = zeros(n,1);
            Dd = 0;
        else
            totnumcalculate = 2;
            try
                [Vv,Dd] = eigs(giant_lap,2,'sm');
                classeigvec = Vv(:,totnumcalculate-classeigvecnum+1);
            catch
                warning('eigs had a problem');
                classeigvec = zeros(n,1);
                Vv = zeros(n,1);
                Dd = 0;
            end
        end
        vout{1} = Vv;
        vout{2} = Dd;
    end

fh = @(x) graph_pow_lap_helper(x,graph_pow);
[class,vout] = base_giant_classifier(fh, obj, varargin{:});
V = vout{1};
D = vout{2};

end
